import { Controller, Get, Param, BadRequestException } from '@nestjs/common';
import { NotificationsService } from './notifications.service';

@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get(':userGuid')
  async findAll(@Param('userGuid') userGuid: string) {
    const notifications = await this.notificationsService.findAll(userGuid);
    if (!notifications) {
      throw new BadRequestException('User not found');
    }
    return notifications;
  }
}
