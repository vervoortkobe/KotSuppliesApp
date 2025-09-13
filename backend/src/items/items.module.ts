import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ItemsController } from './items.controller';
import { ItemsService } from './items.service';
import { Item } from '../entities/item.entity';
import { List } from '../entities/list.entity';
import { Category } from '../entities/category.entity';
import { Image } from '../entities/image.entity';
import { Notification } from '../entities/notification.entity';
import { NotificationsService } from '../notifications/notifications.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([Item, List, Category, Image, Notification]),
  ],
  controllers: [ItemsController],
  providers: [ItemsService, NotificationsService],
})
export class ItemsModule {}
