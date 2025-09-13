import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Notification } from '../entities/notification.entity';
import { User } from '../entities/user.entity';
import { List } from '../entities/list.entity';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectRepository(Notification)
    private notificationRepository: Repository<Notification>,
    @InjectRepository(User) private userRepository: Repository<User>,
  ) {}

  async findAll(userGuid: string) {
    return this.notificationRepository.find({
      where: { user: { guid: userGuid } },
      relations: ['list'],
      order: { createdAt: 'DESC' },
    });
  }

  async notifyUsers(list: List, excludeUser: User | null, message: string) {
    const notifications = list.users
      .filter((user) => !excludeUser || user.guid !== excludeUser.guid)
      .map((user) => {
        const notification = new Notification();
        notification.message = message;
        notification.user = user;
        notification.list = list;
        return notification;
      });
    await this.notificationRepository.save(notifications);
  }
}
