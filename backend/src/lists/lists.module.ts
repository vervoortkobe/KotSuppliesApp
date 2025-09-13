import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ListsController } from './lists.controller';
import { ListsService } from './lists.service';
import { List } from '../entities/list.entity';
import { User } from '../entities/user.entity';
import { Category } from '../entities/category.entity';
import { Item } from '../entities/item.entity';
import { Notification } from '../entities/notification.entity';
import { NotificationsService } from '../notifications/notifications.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([List, User, Category, Item, Notification]),
  ],
  controllers: [ListsController],
  providers: [ListsService, NotificationsService],
})
export class ListsModule {}
