import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from '../entities/user.entity';
import { Notification } from '../entities/notification.entity';
import { List } from '../entities/list.entity';
import { Image } from '../entities/image.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, Notification, List, Image])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
