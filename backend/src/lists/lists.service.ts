import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { List } from '../entities/list.entity';
import { User } from '../entities/user.entity';
import { Category } from '../entities/category.entity';
import { CreateListDto, UpdateListDto } from './dto';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class ListsService {
  constructor(
    @InjectRepository(List) private listRepository: Repository<List>,
    @InjectRepository(User) private userRepository: Repository<User>,
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
    private notificationsService: NotificationsService,
  ) {}

  async create(createListDto: CreateListDto) {
    const creator = await this.userRepository.findOneBy({
      guid: createListDto.creatorGuid,
    });

    if (!creator) {
      throw new BadRequestException('Creator (user) not found');
    }

    const list = new List();
    list.title = createListDto.title;
    list.description = createListDto.description || '';
    list.guid = uuidv4();
    list.type = createListDto.type;
    list.shareCode = Math.random().toString(36).substring(2, 8);

    list.users = [creator];

    if (createListDto.type === 'image_count') {
      const defaultCategory = new Category();
      defaultCategory.name = 'uncategorized';
      defaultCategory.list = list;
      list.categories = [defaultCategory];
    }

    return this.listRepository.save(list);
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
    const list = await this.findOne(guid);
    if (!list) {
      throw new BadRequestException('List not found');
    }
    await this.listRepository.remove(list);
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
