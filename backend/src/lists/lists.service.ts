import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { List } from '../entities/list.entity';
import { User } from '../entities/user.entity';
import { Category } from '../entities/category.entity';
import { Item } from '../entities/item.entity';
import { Notification } from '../entities/notification.entity';
import { CreateListDto, UpdateListDto } from './dto';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class ListsService {
  constructor(
    @InjectRepository(List) private listRepository: Repository<List>,
    @InjectRepository(User) private userRepository: Repository<User>,
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
    @InjectRepository(Item) private itemRepository: Repository<Item>,
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    private notificationsService: NotificationsService,
  ) {}

  async create(createListDto: CreateListDto) {
    if (
      !createListDto.type ||
      !['image_count', 'check'].includes(createListDto.type)
    ) {
      throw new BadRequestException(
        'Invalid list type. Must be either "image_count" or "check"',
      );
    }

    const creator = await this.userRepository.findOneBy({
      guid: createListDto.creatorGuid,
    });
    if (!creator) {
      throw new BadRequestException('Creator (user) not found');
    }

    let list = new List();
    list.title = createListDto.title;
    list.description = createListDto.description || '';
    list.guid = uuidv4();
    list.creatorGuid = createListDto.creatorGuid;
    list.type = createListDto.type as 'image_count' | 'check';
    list.shareCode = Math.random().toString(36).substring(2, 8);

    const savedList = await this.listRepository.save(list);

    if (createListDto.type === 'image_count') {
      const defaultCategory = new Category();
      defaultCategory.guid = uuidv4();
      defaultCategory.name = 'uncategorized';
      defaultCategory.list = savedList;

      await this.categoryRepository.save(defaultCategory);
    }

    savedList.users = [creator];
    const finalList = await this.listRepository.save(savedList);

    if (!finalList.type) {
      finalList.type = createListDto.type as 'image_count' | 'check';
    }

    return finalList;
  }

  async findAll() {
    return this.listRepository.find({
      relations: ['users', 'categories', 'items', 'items.category'],
    });
  }

  async findOne(guid: string) {
    return this.listRepository.findOne({
      where: { guid },
      relations: ['users', 'categories', 'items', 'items.category'],
    });
  }

  async findByShareCode(shareCode: string) {
    return this.listRepository.findOne({
      where: { shareCode },
      relations: ['users', 'categories', 'items', 'items.category'],
    });
  }

  async update(guid: string, updateListDto: UpdateListDto) {
    const list = await this.findOne(guid);
    if (!list) {
      throw new BadRequestException('List not found');
    }
    if (updateListDto.title) list.title = updateListDto.title;
    if (updateListDto.description) list.description = updateListDto.description;
    return this.listRepository.save(list);
  }

  async delete(guid: string, userGuid: string) {
    const list = await this.listRepository.findOne({
      where: { guid },
      relations: ['users', 'categories', 'items'],
    });

    if (!list) {
      throw new BadRequestException('List not found');
    }

    // Check if user is the creator
    if (list.creatorGuid !== userGuid) {
      throw new BadRequestException('Only the creator can delete this list');
    }

    // Delete all related entities in the correct order to avoid foreign key constraints

    // 1. Delete notifications referencing this list
    await this.notificationRepository.delete({ list: { guid } });

    // 2. Delete items first (they reference both list and categories)
    await this.itemRepository.delete({ list: { guid } });

    // 3. Delete categories (they reference the list)
    await this.categoryRepository.delete({ list: { guid } });

    // 4. Clear the many-to-many relationship with users
    list.users = [];
    await this.listRepository.save(list);

    // 5. Finally delete the list
    await this.listRepository.delete({ guid });

    return { message: 'List deleted' };
  }

  async addUser(listGuid: string, userGuid: string) {
    const list = await this.findOne(listGuid);
    const user = await this.userRepository.findOneBy({ guid: userGuid });
    if (!list || !user) {
      throw new BadRequestException('List or user not found');
    }
    list.users = list.users || [];
    if (!list.users.find((u) => u.guid === userGuid)) {
      list.users.push(user);
      await this.listRepository.save(list);
      await this.notificationsService.notifyUsers(
        list,
        user,
        `User ${user.username} joined list ${list.title}`,
      );
    }
    return list;
  }

  async removeUser(listGuid: string, userGuid: string) {
    const list = await this.findOne(listGuid);
    const user = await this.userRepository.findOneBy({ guid: userGuid });
    if (!list || !user) {
      throw new BadRequestException('List or user not found');
    }
    list.users = list.users.filter((u) => u.guid !== userGuid);
    await this.listRepository.save(list);
    await this.notificationsService.notifyUsers(
      list,
      user,
      `User ${user.username} left list ${list.title}`,
    );
    return list;
  }

  async leaveList(listGuid: string, userGuid: string) {
    const list = await this.findOne(listGuid);
    const user = await this.userRepository.findOneBy({ guid: userGuid });
    if (!list || !user) {
      throw new BadRequestException('List or user not found');
    }

    // Check if user is the creator
    if (list.creatorGuid === userGuid) {
      throw new BadRequestException(
        'Creator cannot leave the list. Delete the list instead.',
      );
    }

    // Check if user is actually in the list
    const userInList = list.users.find((u) => u.guid === userGuid);
    if (!userInList) {
      throw new BadRequestException('User is not a member of this list');
    }

    list.users = list.users.filter((u) => u.guid !== userGuid);
    await this.listRepository.save(list);
    await this.notificationsService.notifyUsers(
      list,
      user,
      `User ${user.username} left list ${list.title}`,
    );
    return { message: 'Successfully left the list' };
  }
}
