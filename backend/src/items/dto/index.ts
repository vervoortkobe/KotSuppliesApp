import {
  IsString,
  IsNumber,
  IsBoolean,
  IsOptional,
  IsArray,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateItemDto {
  @IsString()
  title: string;

  @IsNumber()
  @IsOptional()
  amount?: number;

  @IsBoolean()
  @IsOptional()
  checked?: boolean;

  @IsString()
  @IsOptional()
  categoryGuid?: string;
}

export class UpdateItemDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsNumber()
  @IsOptional()
  amount?: number;

  @IsBoolean()
  @IsOptional()
  checked?: boolean;

  @IsString()
  @IsOptional()
  categoryGuid?: string;
}

export class BulkItemDto {
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => UpdateItemDto)
  items: { guid: string; data: UpdateItemDto }[];
}
