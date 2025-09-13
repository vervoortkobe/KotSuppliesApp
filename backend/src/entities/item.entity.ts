import { Entity, PrimaryColumn, Column, ManyToOne } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { List } from './list.entity';
import { Category } from './category.entity';

@Entity()
export class Item {
  @PrimaryColumn('uuid')
  guid: string = uuidv4();

  @Column()
  title: string;

  @Column({ nullable: true })
  amount: number;

  @Column({ nullable: true })
  imageGuid: string;

  @Column({ default: false })
  checked: boolean;

  @ManyToOne(() => List, (list) => list.items)
  list: List;

  @ManyToOne(() => Category, (category) => category.items, { nullable: true })
  category: Category;
}
