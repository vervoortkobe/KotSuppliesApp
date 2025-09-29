import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { List } from '../entities/list.entity';
import { User } from '../entities/user.entity';
import { Category } from '../entities/category.entity';
import { Item } from '../entities/item.entity';
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
    list.type = createListDto.type as 'image_count' | 'check';
    list.shareCode = Math.random().toString(36).substring(2, 8);

    // First save the list without categories
    const savedList = await this.listRepository.save(list);

    // Then create the default category for image_count lists
    if (createListDto.type === 'image_count') {
      const defaultCategory = new Category();
      defaultCategory.guid = uuidv4(); // Explicitly set the GUID
      defaultCategory.name = 'uncategorized';
      defaultCategory.list = savedList; // Reference the saved list

      // Save the category separately
      await this.categoryRepository.save(defaultCategory);
    }

    // Add the creator to the users and save again
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

  async update(guid: string, updateListDto: UpdateListDto) {
    const list = await this.findOne(guid);
    if (!list) {
      throw new BadRequestException('List not found');
    }
    if (updateListDto.title) list.title = updateListDto.title;
    if (updateListDto.description) list.description = updateListDto.description;
    return this.listRepository.save(list);
  }

  async delete(guid: string) {
    // Use a simple approach without transactions to avoid cascade issues
    const list = await this.listRepository.findOne({
      where: { guid },
      relations: ['users', 'categories', 'items'],
    });

    if (!list) {
      throw new BadRequestException('List not found');
    }

    // Delete items one by one
    if (list.items && list.items.length > 0) {
      for (const item of list.items) {
        await this.itemRepository.delete(item.guid);
      }
    }

    // Delete categories one by one
    if (list.categories && list.categories.length > 0) {
      for (const category of list.categories) {
        await this.categoryRepository.delete(category.guid);
      }
    }

    // Remove user relationships by deleting the list (this will clear the join table)
    await this.listRepository.delete(guid);

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
}
