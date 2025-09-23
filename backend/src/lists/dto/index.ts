import { IsString, IsEnum, IsOptional } from 'class-validator';

export class CreateListDto {
  @IsString()
  title: string;

  @IsString()
  @IsOptional()
  description?: string;

  @IsEnum(['image_count', 'check'])
  type: 'image_count' | 'check';

  @IsString()
  creatorGuid: string;
}

export class UpdateListDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsString()
  @IsOptional()
  description?: string;
}
