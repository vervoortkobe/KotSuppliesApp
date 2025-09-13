import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Category } from '../entities/category.entity';
import { List } from '../entities/list.entity';
import { CreateCategoryDto, UpdateCategoryDto } from './dto';

@Injectable()
export class CategoriesService {
  constructor(
    @InjectRepository(Category)
    private categoryRepository: Repository<Category>,
    @InjectRepository(List) private listRepository: Repository<List>,
  ) {}

  async create(listGuid: string, createCategoryDto: CreateCategoryDto) {
    const list = await this.listRepository.findOneBy({ guid: listGuid });
    if (!list) {
      throw new BadRequestException('List not found');
    }
    if (list.type !== 'image_count') {
      throw new BadRequestException(
        'Categories are only for image_count lists',
      );
    }
    const category = new Category();
    category.name = createCategoryDto.name;
    category.list = list;
    return this.categoryRepository.save(category);
  }

  async findOne(listGuid: string, categoryGuid: string) {
    return this.categoryRepository.findOne({
      where: { guid: categoryGuid, list: { guid: listGuid } },
      relations: ['list', 'items'],
    });
  }

  async update(
    listGuid: string,
    categoryGuid: string,
    updateCategoryDto: UpdateCategoryDto,
  ) {
    const category = await this.findOne(listGuid, categoryGuid);
    if (!category) {
      throw new BadRequestException('Category not found');
    }
    category.name = updateCategoryDto.name;
    return this.categoryRepository.save(category);
  }

  async delete(listGuid: string, categoryGuid: string) {
    const category = await this.findOne(listGuid, categoryGuid);
    if (!category) {
      throw new BadRequestException('Category not found');
    }
    if (category.name === 'uncategorized') {
      throw new BadRequestException('Cannot delete default category');
    }
    await this.categoryRepository.remove(category);
    return { message: 'Category deleted' };
  }
}
