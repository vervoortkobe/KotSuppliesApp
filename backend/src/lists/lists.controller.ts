import {
  Controller,
  Post,
  Body,
  Get,
  Param,
  Put,
  Delete,
  BadRequestException,
} from '@nestjs/common';
import { ListsService } from './lists.service';
import { CreateListDto, UpdateListDto } from './dto';

@Controller('lists')
export class ListsController {
  constructor(private readonly listsService: ListsService) {}

  @Post()
  async create(@Body() createListDto: CreateListDto) {
    return this.listsService.create(createListDto);
  }

  @Get(':guid')
  async findOne(@Param('guid') guid: string) {
    const list = await this.listsService.findOne(guid);
    if (!list) {
      throw new BadRequestException('List not found');
    }
    return list;
  }

  @Put(':guid')
  async update(
    @Param('guid') guid: string,
    @Body() updateListDto: UpdateListDto,
  ) {
    return this.listsService.update(guid, updateListDto);
  }

  @Delete(':guid')
  async delete(@Param('guid') guid: string) {
    return this.listsService.delete(guid);
  }

  @Post(':listGuid/add-user/:userGuid')
  async addUser(
    @Param('listGuid') listGuid: string,
    @Param('userGuid') userGuid: string,
  ) {
    return this.listsService.addUser(listGuid, userGuid);
  }

  @Post(':listGuid/remove-user/:userGuid')
  async removeUser(
    @Param('listGuid') listGuid: string,
    @Param('userGuid') userGuid: string,
  ) {
    return this.listsService.removeUser(listGuid, userGuid);
  }
}
