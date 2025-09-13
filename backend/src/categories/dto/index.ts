import { IsString } from 'class-validator';

export class CreateCategoryDto {
  @IsString()
  name: string;
}

export class UpdateCategoryDto {
  @IsString()
  name: string;
}
