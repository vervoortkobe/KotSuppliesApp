import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { Notification } from '../entities/notification.entity';
import { User } from '../entities/user.entity';
import { List } from '../entities/list.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Notification, User, List])],
  controllers: [NotificationsController],
  providers: [NotificationsService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
