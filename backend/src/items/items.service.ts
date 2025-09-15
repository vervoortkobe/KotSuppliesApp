import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Item } from '../entities/item.entity';
import { List } from '../entities/list.entity';
import { Category } from '../entities/category.entity';
import { Image } from '../entities/image.entity';
import { CreateItemDto, UpdateItemDto, BulkItemDto } from './dto';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class ItemsService {
  constructor(
    @InjectRepository(Item) private itemRepository: Repository<Item>,
    @InjectRepository(List) private listRepository: Repository<List>,
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
    @InjectRepository(Image) private imageRepository: Repository<Image>,
    private notificationsService: NotificationsService,
  ) {}

  async create(
    listGuid: string,
    createItemDto: CreateItemDto,
    file?: Express.Multer.File,
  ) {
    const list = await this.listRepository.findOne({
      where: { guid: listGuid },
      relations: ['users', 'categories'],
    });
    if (!list) {
      throw new BadRequestException('List not found');
    }
    if (list.type === 'image_count' && createItemDto.checked !== undefined) {
      throw new BadRequestException('Checked field is only for check lists');
    }
    if (list.type === 'check' && (createItemDto.amount !== undefined || file)) {
      throw new BadRequestException(
        'Amount and image fields are only for image_count lists',
      );
    }
    const item = new Item();
    item.title = createItemDto.title;
    item.amount = createItemDto.amount || 1;
    item.checked = createItemDto.checked || false;
    item.list = list;
    if (createItemDto.categoryGuid) {
      const category = await this.categoryRepository.findOneBy({
        guid: createItemDto.categoryGuid,
        list: { guid: listGuid },
      });
      if (!category) {
        throw new BadRequestException('Category not found');
      }
      item.category = category;
    }
    if (file) {
      const image = new Image();
      image.data = file.buffer;
      image.mimeType = file.mimetype;
      const savedImage = await this.imageRepository.save(image);
      item.imageGuid = savedImage.guid;
    }
    const savedItem = await this.itemRepository.save(item);
    await this.notificationsService.notifyUsers(
      list,
      null,
      `Item ${item.title} added to list ${list.title}`,
    );
    return savedItem;
  }

  async findOne(listGuid: string, itemGuid: string) {
    return this.itemRepository.findOne({
      where: { guid: itemGuid, list: { guid: listGuid } },
      relations: ['list', 'category'],
    });
  }

  async update(
    listGuid: string,
    itemGuid: string,
    updateItemDto: UpdateItemDto,
    file?: Express.Multer.File,
  ) {
    const item = await this.findOne(listGuid, itemGuid);
    if (!item) {
      throw new BadRequestException('Item not found');
    }
    const list = await this.listRepository.findOneBy({ guid: listGuid });
    if (!list) {
      throw new BadRequestException('List not found');
    }

    if (list.type === 'image_count' && updateItemDto.checked !== undefined) {
      throw new BadRequestException('Checked field is only for check lists');
    }
    if (list.type === 'check' && (updateItemDto.amount !== undefined || file)) {
      throw new BadRequestException(
        'Amount and image fields are only for image_count lists',
      );
    }
    if (updateItemDto.title) item.title = updateItemDto.title;
    if (updateItemDto.amount !== undefined) item.amount = updateItemDto.amount;
    if (updateItemDto.checked !== undefined)
      item.checked = updateItemDto.checked;
    if (updateItemDto.categoryGuid) {
      const category = await this.categoryRepository.findOneBy({
        guid: updateItemDto.categoryGuid,
        list: { guid: listGuid },
      });
      if (!category) {
        throw new BadRequestException('Category not found');
      }
      item.category = category;
    }
    if (file) {
      const image = new Image();
      image.data = file.buffer;
      image.mimeType = file.mimetype;
      const savedImage = await this.imageRepository.save(image);
      item.imageGuid = savedImage.guid;
    }
    const savedItem = await this.itemRepository.save(item);
    await this.notificationsService.notifyUsers(
      list,
      null,
      `Item ${item.title} updated in list ${list.title}`,
    );
    return savedItem;
  }

  async delete(listGuid: string, itemGuid: string) {
    const item = await this.findOne(listGuid, itemGuid);
    if (!item) {
      throw new BadRequestException('Item not found');
    }
    const list = await this.listRepository.findOneBy({ guid: listGuid });
    if (!list) {
      throw new BadRequestException('List not found');
    }
    await this.itemRepository.remove(item);
    await this.notificationsService.notifyUsers(
      list,
      null,
      `Item ${item.title} removed from list ${list.title}`,
    );
    return { message: 'Item deleted' };
  }

  async bulkOperation(listGuid: string, bulkItemDto: BulkItemDto) {
    const list = await this.listRepository.findOne({
      where: { guid: listGuid },
      relations: ['users'],
    });
    if (!list) {
      throw new BadRequestException('List not found');
    }
    type BulkResult =
      | { guid: string; error: string }
      | { guid: string; status: string; item: Item };
    const results: BulkResult[] = [];

    for (const { guid, data } of bulkItemDto.items) {
      const item = await this.findOne(listGuid, guid);
      if (item) {
        if (data.title) item.title = data.title;
        if (data.amount !== undefined) item.amount = data.amount;
        if (data.checked !== undefined) item.checked = data.checked;
        if (data.categoryGuid) {
          const category = await this.categoryRepository.findOneBy({
            guid: data.categoryGuid,
            list: { guid: listGuid },
          });
          if (!category) {
            results.push({ guid, error: 'Category not found' });
            continue;
          }
          item.category = category;
        }
        const savedItem = await this.itemRepository.save(item);
        results.push({ guid, status: 'updated', item: savedItem });
        await this.notificationsService.notifyUsers(
          list,
          null,
          `Item ${item.title} updated in list ${list.title}`,
        );
      } else {
        results.push({ guid, error: 'Item not found' });
      }
    }
    return results;
  }
}
