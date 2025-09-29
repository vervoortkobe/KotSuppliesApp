import { Entity, PrimaryColumn, Column, ManyToOne, OneToMany } from 'typeorm';
import { v4 as uuidv4 } from 'uuid';
import { List } from './list.entity';
import { Item } from './item.entity';
import { Exclude } from 'class-transformer';

@Entity()
export class Category {
  @PrimaryColumn('uuid')
  guid: string = uuidv4();

  @Column({ default: 'uncategorized' })
  name: string;

  @Exclude()
  @ManyToOne(() => List, (list) => list.categories)
  list: List;

  @OneToMany(() => Item, (item) => item.category)
  items: Item[];
}
