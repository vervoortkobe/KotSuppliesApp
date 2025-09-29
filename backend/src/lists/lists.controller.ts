import {
  Controller,
  Post,
  Body,
  Get,
  Param,
  Put,
  Delete,
  BadRequestException,
  HttpCode,
} from '@nestjs/common';
import { ListsService } from './lists.service';
import { CreateListDto, UpdateListDto } from './dto';

@Controller('lists')
export class ListsController {
  constructor(private readonly listsService: ListsService) {}

  @Post()
  @HttpCode(201)
  async create(@Body() createListDto: CreateListDto) {
    return this.listsService.create(createListDto);
  }

  @Get()
  @HttpCode(200)
  async findAll() {
    return this.listsService.findAll();
  }

  @Get(':guid')
  @HttpCode(200)
  async findOne(@Param('guid') guid: string) {
    const list = await this.listsService.findOne(guid);
    if (!list) {
      throw new BadRequestException('List not found');
    }
    return list;
  }

  @Get('share/:shareCode')
  @HttpCode(200)
  async findByShareCode(@Param('shareCode') shareCode: string) {
    const list = await this.listsService.findByShareCode(shareCode);
    if (!list) {
      throw new BadRequestException('List not found with provided share code');
    }
    return list;
  }

  @Put(':guid')
  @HttpCode(200)
  async update(
    @Param('guid') guid: string,
    @Body() updateListDto: UpdateListDto,
  ) {
    return this.listsService.update(guid, updateListDto);
  }

  @Delete(':guid')
  @HttpCode(200)
  async delete(@Param('guid') guid: string) {
    return this.listsService.delete(guid);
  }

  @Post(':listGuid/add-user/:userGuid')
  @HttpCode(200)
  async addUser(
    @Param('listGuid') listGuid: string,
    @Param('userGuid') userGuid: string,
  ) {
    return this.listsService.addUser(listGuid, userGuid);
  }

  @Post(':listGuid/remove-user/:userGuid')
  @HttpCode(200)
  async removeUser(
    @Param('listGuid') listGuid: string,
    @Param('userGuid') userGuid: string,
  ) {
    return this.listsService.removeUser(listGuid, userGuid);
  }
}
