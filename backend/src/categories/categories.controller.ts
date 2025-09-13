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
import { CategoriesService } from './categories.service';
import { CreateCategoryDto, UpdateCategoryDto } from './dto';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post(':listGuid')
  async create(
    @Param('listGuid') listGuid: string,
    @Body() createCategoryDto: CreateCategoryDto,
  ) {
    return this.categoriesService.create(listGuid, createCategoryDto);
  }

  @Get(':listGuid/:categoryGuid')
  async findOne(
    @Param('listGuid') listGuid: string,
    @Param('categoryGuid') categoryGuid: string,
  ) {
    const category = await this.categoriesService.findOne(
      listGuid,
      categoryGuid,
    );
    if (!category) {
      throw new BadRequestException('Category not found');
    }
    return category;
  }

  @Put(':listGuid/:categoryGuid')
  async update(
    @Param('listGuid') listGuid: string,
    @Param('categoryGuid') categoryGuid: string,
    @Body() updateCategoryDto: UpdateCategoryDto,
  ) {
    return this.categoriesService.update(
      listGuid,
      categoryGuid,
      updateCategoryDto,
    );
  }

  @Delete(':listGuid/:categoryGuid')
  async delete(
    @Param('listGuid') listGuid: string,
    @Param('categoryGuid') categoryGuid: string,
  ) {
    return this.categoriesService.delete(listGuid, categoryGuid);
  }
}
