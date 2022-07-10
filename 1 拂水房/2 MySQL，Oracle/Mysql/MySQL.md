# 一：简介

### 概述

MySQL 最初是由“MySQL AB”公司开发的一套关系型数据库管理系统（RDBMS-RelationalDatabase Mangerment System）。

MySQL 不仅是最流行的开源数据库，而且是业界成长最快的数据库，每天有超过 7 万次的下载量，其应用范围从大型企业到专有的嵌入应用系统。

MySQL AB 是由两个瑞典人和一个芬兰人：David Axmark、Allan Larsson 和 Michael “Monty” Widenius 在瑞典创办的。

在 2008 年初，Sun Microsystems 收购了 MySQL AB 公司。在 2009 年，Oracle 收购了 Sun 公司，使 MySQL 并入 Oracle 的数据库产品线。

# 第四部分、存储引擎

## 1、存储引擎的使用

- 数据库中的各表均被（在创建表时）指定的存储引擎来处理。

- 服务器可用的引擎依赖于以下因素：

  - MySQL 的版本

  - 服务器在开发时如何被配置

  - 启动选项

- 为了解当前服务器中有哪些存储引擎可用，可使用 SHOW ENGINES 语句：

  mysql\> SHOW ENGINES\\G

  ![](../../../4三千道藏/media/caea2762ce36b7c9539bfe13a63918f6.png)

- 在创建表时，可使用 ENGINE 选项为 CREATE TABLE 语句显式指定存储引擎。

  CREATE TABLE TABLENAME (NO INT) ENGINE = MyISAM;

- 如果在创建表时没有显式指定存储引擎，则该表使用当前默认的存储引擎

- 默认的存储引擎可在 my.ini 配置文件中使用 default-storage-engine 选项指定。

- 现有表的存储引擎可使用 ALTER TABLE 语句来改变：ALTER TABLE TABLENAME ENGINE =
  INNODB;

- 为确定某表所使用的存储引擎，可以使用 SHOW CREATE TABLE 或 SHOW TABLE
  STATUS 语句：

  mysql\> SHOW CREATE TABLE emp\\G

  mysql\> SHOW TABLE STATUS LIKE 'emp' \\G

## 14.2、常用的存储引擎

#### 14.2.1、MyISAM 存储引擎

MyISAM 提供了大量的特性，包括全文索引、压缩、空间函数(GIS)等，但 MyISAM**不支持事务和行级锁**(**myisam 改表时会将整个表全锁住)，**有一个毫无疑问的缺陷就是崩溃后无法安全恢复。

- MyISAM 存储引擎是 MySQL 最常用的引擎。

- 支持表锁

- 它管理的表具有以下特征：

  - 使用三个文件表示每个表：

    - 格式文件 — 存储表结构的定义（mytable.frm）

    - 数据文件 — 存储表行的内容（mytable.MYD）

    - 索引文件 — 存储表上索引（mytable.MYI）

  - 灵活的 AUTO_INCREMENT 字段处理

  - 可被转换为压缩、只读表来节省空间

#### 14.2.2、InnoDB 存储引擎

- InnoDB 存储引擎是 MySQL 的缺省引擎。

- **支持行锁和表锁**，支持事务，并发量高，聚簇索引，全文检索，支持外键。

- 它管理的表具有下列主要特征：

  - 每个 InnoDB 表在数据库目录中以.frm 格式文件表示

- InnoDB 表空间 tablespace 被用于存储表的内容
  - 提供一组用来记录事务性活动的日志文件
- 用 COMMIT(提交)、SAVEPOINT 及 ROLLBACK(回滚)支持事务处理
  - 提供全 ACID 兼容
- 在 MySQL 服务器崩溃后提供自动恢复
  - 多版本（MVCC）和行级锁定
- 支持外键及引用的完整性，包括级联删除和更新
  - 默认隔离级别为可重复读

#### 14.2.3、MEMORY 存储引擎

- 使用 MEMORY 存储引擎的表，其数据存储在内存中，且行的长度固定，这两个特点使得 MEMORY 存储引擎非常快。

- MEMORY 存储引擎管理的表具有下列特征：

  - 在数据库目录内，每个表均以.frm 格式的文件表示。

  - 表数据及索引被存储在内存中。

  - 表级锁机制。

  - 不能包含 TEXT 或 BLOB 字段。

- MEMORY 存储引擎以前被称为 HEAP 引擎。

## 14.3、选择合适的存储引擎

- MyISAM 表最适合于**大量的数据读**而少量数据更新的混合操作。MyISAM 表的另一种适用情形是使用压缩的只读表。

- 如果查询中包含**较多的数据更新操作，应使用 InnoDB**。其行级锁机制和多版本的支持为数据读取和更新的混合操作提供了良好的并发机制。

- 可使用 MEMORY 存储引擎来存储非永久需要的数据，或者是能够从基于磁盘的表中重新生成的数据。

查询较多的选择 MYISAM：

InnoDB 的表是根据主键进行展开的 B+tree 的聚集索引。MyIsam 则非聚集型索引，myisam
存储会有两个文件，一个是索引文件，另外一个是数据文件，其中索引文件中的索引指向数据文件中的表数据。

聚集型索引并不是一种单独的索引类型，而是一种存储方式，InnoDB 聚集型索引实际上是在同一结构中保存了 B+tree
索引和数据行。当有聚簇索引时，它的索引实际放在叶子页中。

![image-20200404084731063](../../../4三千道藏/media/image-20200404084731063.png)

innodb 保存时一个.frm 文件，一个.idb 文件.索引文件和数据文件是放在同一个文件中的

myisam 有三个文件，索引文件和数据文件分开存放 .MYD 文件表示数据。.MYI 文件表示索引。.frm 文件

InnoDB 默认可以创建 16 个索引

- InnoDB 支持事务，MyIsam 不支持事务，对于 InnoDB 每一条 SQL 语言都默认封装成事务，自动提交，这样会影响速度，所以最好把多条 SQL 语言放到 begin 和 commit 之间，组成一个事务；
- InnoDB 支持外键，而 MyIsam 不支持，对一个包含外键的 InnoDB 表转成 MyIsam 表会失败
- InnoDB 是聚集索引，数据文件和索引绑定在一块，必须要有主键，通过主键索引效率很高，但是辅助索引需要两次查询，先查询到主键，然后在通过主键查询到数据。因此主键不应该过大。主键过大的时候，其它索引也会很大。而 MyIsam 是非聚集索引，数据和文件是分离的，索引保存的是数据文件的指针，主键索引和辅助索引是独立的。
- InnoDB 不支持全文检索，而 MyIsam 支持全文检索，查询效率上 MyIsam 要高

# 第五章：事务

### 一、概述

事务具有四个特征 ACID

1：原子性（Atomicity）
整个事务中的所有操作，必须作为一个单元全部完成（或全部取消）。事务可以保证多个操作原子性，要么全成功，要么全失败。对于数据库来说事务保证批量的 DML 要么全成功，要么全失败。

实现：利用 undo log 回滚日志，

- (1)当你 delete 一条数据的时候，就需要记录这条数据的信息，回滚的时候，insert 这条旧数据
- (2)当你 update 一条数据的时候，就需要记录之前的旧值，回滚的时候，根据旧值执行 update 操作
- (3)当年 insert 一条数据的时候，就需要这条记录的主键，回滚的时候，根据主键执行 delete 操作

`undo log`记录了这些回滚需要的信息，当事务执行失败或调用了 rollback，导致事务需要回滚，便可以利用 undo log 中的信息将数据回滚到修改之前的样子。

2：一致性（Consistency）
在事务开始之前与结束之后，数据库都保持一致状态。

实现：通过实现其他三个保证一致性

3：隔离性(Isolation)
一个事务不会影响其他事务的运行。

实现：加锁和 MVCC 机制，一个行记录数据有多个版本对快照数据，这些快照数据在`undo log`中。如果一个事务读取的行正在做 DELELE 或者 UPDATE 操作，读取操作不会等行上的锁释放，而是读取该行的快照版本。

4：持久性(Durability)
在事务完成以后，该事务对数据库所作的更改将持久地保存在数据库之中，并不会被回滚。

实现：redo log 重做日志

采用`redo log`解决上面的问题。当做数据修改的时候，不仅在内存中操作，还会在`redo log`中记录这次操作。当事务提交的时候，会将`redo log`日志进行刷盘(`redo log`一部分在内存中，一部分在磁盘上)。当数据库宕机重启的时候，会将`redo log`中的内容恢复到数据库中，再根据`undo log`和`binlog`内容决定回滚数据还是提交数据。
![](../../../4三千道藏/media/Pasted%20image%2020220117163113.png)
`write pos`是当前记录的位置，一边写一边后移，写到第`log_3`文件末尾后就回到`log_0`文件开头。`checkpoint`是当前要释放的位置，也是往后推移并且循环的，释放记录前要把记录更新到数据文件。如果`write pos`追上`checkpoint`，那就表明全部空间都满了，这时候不能再执行新的更新，得停下来先释放掉一些位置，让checkpoint继续推进

当有一条记录需要更新的时候，InnoDB引擎就会先将数据更新到内存，再把记录写到redo log里面，这个时候更新就算完成了。同时，InnoDB引擎会在适当的时候，将这个操作记录更新到磁盘里面，而这个更新往往是在系统比较空闲的时候做,可以设置 `innodb_flush_log_at_trx_commit`为1，表示每次事务的redo log都直接持久化到磁盘中
![](../../../4三千道藏/media/Pasted%20image%2020220117163103.png)
-   执行器先通过引擎取到id=5的这一行。id是为该表主键，因此引擎根据BTREE索引查找找到id=5的这一行。如果该行所在的数据页本来就在内存中，就直接返回给执行器；否则，需要先从磁盘读入内存，然后再返回
    
-   执行器拿到引擎给的行数据，把price值加上1，得到新的一行数据，再调用引擎接口写入这行新数据
    
-   引擎将这行新数据更新到内存中，同时将这个更新操作记录到redo log里面，此时redo log处于prepare状态。然后告知执行器执行完成了，随时可以提交事务。执行器生成这个操作的binlog，并把binlog写入磁盘
    
-   执行器调用引擎的提交事务接口，引擎把刚刚写入的redo log改成提交commit状态，更新完成



事务中存在一些概念：

1.  事务（Transaction）：一批操作（一组 DML）

2.  开启事务（Start Transaction）

3.  回滚事务（rollback）

4.  提交事务（commit）

5.  SET AUTOCOMMIT：禁用或启用事务的自动提交模式

当执行 DML 语句是其实就是开启一个事务

关于事务的回滚需要注意：

只能回滚 insert、delete 和 update 语句，不能回滚 select（回滚 select 没有任何意义），对于 create、drop、alter 这些无法回滚.

事务只对 DML 有效果。

注意：rollback，或者 commit 后事务就结束了。

### 二、事务的提交与回滚演示

1. 创建表

   ```sql
   create table user(id int(11)) primary key not null auto_increment,username varchar(30),password varchar(30)) ENGINE = InnoDB DEFAULT CHARSET=utf-8
   ```

2. 查询表中数据

3. 开启事务 START TRANSACTION;

4. 插入数据

   insert into user (username,password) values ('zhangsan','123');

5. 查看数据

6. 修改数

7. 查看数据

8. 回滚事务

9. 查看数据

### 三、自动提交模式

- 自动提交模式用于决定新事务如何及何时启动。

- 启用自动提交模式：

  - 如果自动提交模式被启用，则单条 DML 语句将缺省地开始一个新的事务。

  - 如果该语句执行成功，事务将自动提交，并永久地保存该语句的执行结果。

  - 如果语句执行失败，事务将自动回滚，并取消该语句的结果。

  - 在自动提交模式下，仍可使用 START
    TRANSACTION 语句来显式地启动事务。这时，一个事务仍可包含多条语句，直到这些语句被统一提交或回滚。

- 禁用自动提交模式：

  - 如果禁用自动提交，事务可以跨越多条语句。

  - 在这种情况下，事务可以用 COMMIT 和 ROLLBACK 语句来显式地提交或回滚。

- 自动提交模式可以通过服务器变量 AUTOCOMMIT 来控制。

- 例如：

mysql\> SET AUTOCOMMIT = OFF；

mysql\> SET AUTOCOMMIT = ON；

或

mysql\> SET SESSION AUTOCOMMIT = OFF；

mysql\> SET SESSION AUTOCOMMIT = ON；

show variables like '%auto%'; -- 查看变量状态

### 四、事务的隔离级别

#### 当前读与快照读

#### 1、一致性问题

事务的隔离级别决定了事务之间可见的级别。

当多个客户端并发地访问同一个表时，可能出现下面的一致性问题：

（1）脏读取（Dirty Read）：事务 A 读到了事务 B 未提交的数据。

（2）不可重复读（Non-repeatable Read）

事务 A 第一次查询得到一行记录 row1，事务 B 提交修改后，事务 A 第二次查询得到 row1，但列内容发生了变化。

（3）幻像读（Phantom Read）

事务 A 第一次查询得到一行记录 row1，事务 B 提交修改后，事务 A 第二次查询得到两行记录 row1 和 row2。

InnoDB 引擎，可重复读隔离级别，，使用**当前读**时。

表现：

一个事务(同一个 read view)在前后两次查询同一范围的时候，后一次查询看到了前一次查询没有看到的行。

幻像读是指在同一个事务中以前没有的行，由于其他事务的提交而出现的新行。

注意：

1、在可重复读隔离级别下，普通查询是快照读，是不会看到别的事务插入的数据的，幻读只在**当前读**下才会出现。
幻读专指**新插入的行**，读到原本存在行的更新结果不算。因为**当前读**的作用就是能读到所有已经提交记录的最新值。

影响：

会造成一个事务中先产生的锁，无法锁住后加入的满足条件的行。

产生数据一致性问题，在一个事务中，先对符合条件的目标行做变更，而在事务提交前有新的符合目标条件的行加入。这样通过 binlog 恢复的数据是会将所有符合条件的目标行都进行变更的。

原因：

行锁只能锁住行，即使把所有的行记录都上锁，也阻止不了新插入的记录。

解决：

- 将两行记录间的空隙加上锁，阻止新记录的插入；这个锁称为**间隙锁**。
- 间隙锁与间隙锁之间没有冲突关系。跟间隙锁存在冲突关系的，是**往这个间隙中插入一个记录**这个操作。

当前读情况下加间隙锁，快照读情况下 mysql 会自动使用 MVCC 机制解决幻读。

#### 2、封锁

封锁粒度：行级锁以及表级锁

类型：

1：读写锁：互斥锁（X锁，写锁）；共享锁（S锁，读锁）

2：意向锁：

封锁协议：

1：加互斥锁，直到事务结束才释放锁

2：加共享锁，读完马上释放锁：

3：加共享锁，直到事务结束才释放锁；

#### 3、四个隔离级别

InnoDB 实现了四个隔离级别，用以控制事务所做的修改，并将修改通告至其它并发的事务：

- 读未提交（READ UMCOMMITTED）

允许一个事务可以看到其他事务未提交的修改。

原理：写数据时加上排他锁，直到事务结束， 读的时候不加锁。

- 读已提交（READ COMMITTED）

允许一个事务只能看到其他事务已经提交的修改，未提交的修改是不可见的。（Oracle 默认）

原理：写数据的时候加上排他锁， 直到事务结束， 读的时候加上共享锁， 读完数据立刻释放。(共享锁规则 1)

- 可重复读（REPEATABLE READ）

确保如果在一个事务中执行两次相同的 SELECT 语句，都能得到相同的结果，不管其他事务是否提交这些修改。
（银行总账）**该隔离级别为 InnoDB 的缺省设置。**

原理：写数据的时候加上排他锁， 直到事务结束， 读数据的时候加共享锁， 也是直到事务结束。(共享锁规则 2)

- 串行化（SERIALIZABLE） 【序列化】

将一个事务与其他事务完全地隔离。

原理：严格有序执行，事务不能并发执行。

例:A 可以开启事物,B 也可以开启事物

A 在事物中执行 DML 语句时,未提交

B 不以执行 DML,DQL 语句

**隔离级别与一致性问题的关系**

![](../../../4三千道藏/media/53867db086b0bde31ad0bf067185b4ee.png)

**设置服务器缺省隔离级别**

通过修改配置文件设置

- 可以在 my.ini 文件中使用 transaction-isolation 选项来设置服务器的缺省事务隔离级别。

- 该选项值可以是：

  - READ-UNCOMMITTED

  - READ-COMMITTED

  - REPEATABLE-READ

  - SERIALIZABLE

- 例如：

[mysqld]

transaction-isolation = READ-COMMITTED

通过命令动态设置隔离级别

- 隔离级别也可以在运行的服务器中动态设置，应使用 SET TRANSACTION ISOLATION
  LEVEL 语句。

- 其语法模式为：

SET [GLOBAL \| SESSION] TRANSACTION ISOLATION LEVEL \<isolation-level\>

其中的\<isolation-level\>可以是：

- READ UNCOMMITTED

  - READ COMMITTED

  - REPEATABLE READ

  - SERIALIZABLE

- 例如： SET TRANSACTION ISOLATION LEVEL **REPEATABLE READ**;

**隔离级别的作用范围**

- 事务隔离级别的作用范围分为两种：

  - 全局级：对所有的会话有效

  - 会话级：只对当前的会话有效

- 例如，设置会话级隔离级别为 READ COMMITTED ：

mysql\> SET TRANSACTION ISOLATION LEVEL READ COMMITTED；

或：

mysql\> SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED；

- 设置全局级隔离级别为 READ COMMITTED ：

mysql\> SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED；

**查看隔离级别**

- 服务器变量 tx_isolation（包括会话级和全局级两个变量）中保存着当前的会话隔离级别。

- 为了查看当前隔离级别，可访问 tx_isolation 变量：

  1.查看当前会话隔离级别

  select @@tx_isolation;

  2.查看系统当前隔离级别

  select @@global.tx_isolation;

  3.设置当前会话隔离级别

  set session transaction isolatin level repeatable read;

  4.设置系统当前隔离级别

  set global transaction isolation level repeatable read;

对比 Oracle 查询隔离级别：

```sqlite
1）：

declare
trans_id Varchar2(100);
begin
trans_id := dbms_transaction.local_transaction_id( TRUE );
end;

2）：

SELECT s.sid, s.serial#,CASE BITAND(t.flag, POWER(2, 28))
WHEN 0 THEN 'READ COMMITTED'
ELSE 'SERIALIZABLE' END AS isolation_level
FROM v$transaction t
JOIN v$session s ON t.addr = s.taddr AND s.sid = sys_context('USERENV', 'SID');
```

#### 4、并发事务与隔离级别示例

read uncommitted(未提交读) --脏读(Drity Read)：

| 会话一                                                       | 会话二                  |
| ------------------------------------------------------------ | ----------------------- |
| mysql\> prompt s1\>                                          | mysql\> use bjpowernode |
| s1\>use bjpowernode                                          | mysql\> prompt s2\>     |
| s1\>create table tx ( id int(11), num int (10) );            |                         |
| s1\>set global transaction isolation level read uncommitted; |                         |
| s1\>start transaction;                                       |                         |
|                                                              | s2\>start transaction;  |
| s1\>insert into tx values (1,10);                            |                         |
|                                                              | s2\>select \* from tx;  |
| s1\>rollback;                                                |                         |
|                                                              | s2\>select \* from tx;  |

read committed(已提交读)

| 会话一                                                      | 会话二                 |
| ----------------------------------------------------------- | ---------------------- |
| s1\> set global transaction isolation level read committed; |                        |
| s1\>start transaction;                                      |                        |
|                                                             | s2\>start transaction; |
| s1\>insert into tx values (1,10);                           |                        |
| s1\>select \* from tx;                                      |                        |
|                                                             | s2\>select \* from tx; |
| s1\>commit;                                                 |                        |
|                                                             | s2\>select \* from tx; |

repeatable read(可重复读)

| 会话一                                                       | 会话二                 |
| ------------------------------------------------------------ | ---------------------- |
| s1\> set global transaction isolation level repeatable read; |                        |
| s1\>start transaction;                                       | s2\>start transaction; |
| s1\>select \* from tx;                                       |                        |
| s1\>insert into tx values (1,10);                            |                        |
|                                                              | s2\>select \* from tx; |
| s1\>commit;                                                  |                        |
|                                                              | s2\>select \* from tx; |

### 五：底层实现

redolog：重做日志，保证了事务的持久性。事务开启后，只要开始改变数据信息就会持续写入 redo buffer 中，具体落盘可以指定不同的策略。在数据库发生意外故障时，尚有修改的数据未写入磁盘，在重启 mysql 服务的时候，根据 redo log 恢复事务修改后的新数据。

脏页：当内存数据页跟磁盘数据页内容不一样的时候，称内存也为脏页。几种情况下会刷脏页：

- redolog写满了，整个系统不能再接受更新了。
- 内存不足，需要先将脏页写到磁盘
- mysql空闲的时候或正常关闭的时候。

Redo buffer 持久化到 Redo log 的策略有三种：
取值 0 每秒一次进行提交持久化[可能丢失一秒内 的事务数据]
取值 1 默认值，每次事务提交执行 Redo buffer --> Redo log OS cache -->flush cache to disk [最安全，性能最差的方式]
取值 2 每次事务提交到系统缓存 OS cache，再每一秒从系统缓存中执行持久化 操作

undolog：回滚日志，用于记录数据被修改前的信息，实现事务的原子性。update 操作会将当前数据加入到 undolog 中，然后使用行中的隐藏字段 DB_ROLL——PTR 回滚字段执行的前一个版本的数据。

binglog 是一个二进制的日志文件，会记录 mysql 的数据更新或潜在个跟新 （delete from table where id =xxx）

主从复制就是依靠 binglog

### 六：MVCC

Multi-Version Concurrency Control，多版本并发控制，MVCC 在 MySQL InnoDB 中的实现主要是为了提高数据库并发性能，用更好的方式去处理读-写冲突，做到即使有读写冲突时，也能做到不加锁，非阻塞并发读。

当前读：读取记录的最新版本，读取时还要保证其他并发事务不能修改当前记录，会对读取的几率进行加锁。

快照读：不加锁的非阻塞读，快照读的前提是隔离级别不是串行级别，串行级别下的快照读会退化成当前读；

#### 实现原理

它的实现原理主要是依赖记录中的 3 个隐式字段，undo 日志 ，Read View 来实现的。

**隐式字段：**

DB_TRX_ID,DB_ROLL_PTR,DB_ROW_ID 等字段

- DB_TRX_ID
  6byte，最近修改(修改/插入)事务 ID：记录创建这条记录/最后一次修改该记录的事务 ID
- DB_ROLL_PTR
  7byte，回滚指针，指向这条记录的上一个版本（存储于 rollback segment 里）
- DB_ROW_ID
  6byte，隐含的自增 ID（隐藏主键），如果数据表没有主键，InnoDB 会自动以 DB_ROW_ID 产生一个聚簇索引
- 实际还有一个删除 flag 隐藏字段, 既记录被更新或删除并不代表真的删除，而是删除 flag 变了

**undo 日志**

**ReadView 读视图**

就是事务进行快照读操作的时候生产的读视图(Read View)，在该事务执行的快照读的那一刻，会生成数据库系统当前的一个快照，记录并维护系统当前活跃事务的 ID(当每个事务开启时，都会被分配一个 ID, 这个 ID 是递增的，所以最新的事务，ID 值越大)

如何实现读已提交和可重复读呢？就是生成 ReadView 的时机不同。

对读已提交来说，事务中的每次读操作都会生成一个新的 ReadView，也就是说，如果这期间某个事务提交了，那么它就会从 ReadView 中移除。这样确保事务每次读操作都能读到相对比较新的数据

而对可重复读来说，事务只有在第一次进行读操作时才会生成一个 ReadView，后续的读操作都会重复使用这个 ReadView。也就是说，如果在此期间有其他事务提交了，那么对于可重复读来说也是不可见的，因为对它来说，事务活跃状态在第一次进行读操作时就已经确定下来，后面不会修改了。

通过在每行记录的后边保存两个隐藏的列来实现。这两个列， 一个保存了行的创建时间，一个保存了行的过期时间， 当然存储的并不是实际的时间值，而是系统版本号。

- **undo log** :undo log 中记录某行数据的多个版本的数据。
- **read view** :用来判断当前版本数据的可见性

**MVCC 的实现，是通过保存数据在某个时间点的快照来实现的**。也就是说，不管需要执行多长时间，每个事务看到的数据是一致的。**根据事务开始的时间不同，每个事务对同一张表，同一时刻看到的数据可能是不一样的**。不同存储引擎的 MVCC 实现是不同的，典型的有乐观（optimistic）并发控制和悲观（pessimistic）并发控制。

新增：会给行数据添加两个隐藏列，数据版本号和删除版本号。数据版本号值为插入时的事务 id，删除版本号默认为 null。

删除：会给行数据的删除版本号设一个当前事务 id 值。

修改：会先拷贝一份行数据，再把原先行数据的删除版本号设值，再修改拷贝的数据，并改变数据版本号值。

查询：必须保证当前事务 ID 大于等于该行数据的数据版本号，并且删除版本号必须为 null 或者大于当前事务 ID 值。

大多数情况下可以代替行级锁，降低系统开销

InnoDB 使用的是行锁。而 InnoDB 的事务分为四个隔离级别，其中默认的隔离级别 REPEATABLE READ 需要两个不同的事务相互之间不能影响，而且还能支持并发，这点悲观锁是达不到的，所以 REPEATABLE READ 采用的就是乐观锁，而乐观锁的实现采用的就是 MVCC。正是因为有了 MVCC，才造就了 InnoDB 强大的事务处理能力。

因为有行 id，事务 id

redo 日志和 undo 日志

用于回滚，先 redo 在 undo

undo 日志记录操作之前的数据

redo 是

mysql 的删除并不是物理上的删除，而是标记……

![image-20210224153355722](../../../4三千道藏/media/image-20210224153355722.png)

当执行查询 SQL 时会生成一致性视图 read-view，他由执行查询时所有未提交事务 id 数组（数组里最小的 id 为 min_id)和已创建的最大事务 id（max_id)组成，查询的数据结果需要跟 read-view 做对比从而得到快照结果：

对比规则：

如果落在绿色部分（trx_is <min_id)，表示这个版本是已提交的事务生成的，这个数据是可见的，

如果落在红色部分(trx_id > max_id)，表示这个版本是由将来启动的事务生成的，是肯定不可见的，

如果落在黄色部分，那就包括两种情况：

- 若 row 的 trx_id 在数组中，表示这个版本是由还没提交的事务生成的，不可见，当前自己的事务是可见的
- 若 row 的 trx_id 不在数组中，表示这个版本已经提交了事务生成的，可见。

# 第六章：索引

## 16.1、索引简介

**查询数据过多，关联太多表，使用太多 join，没有利用索引，等导致性能下降**

索引被用来快速找出在一个列上用一特定值的行。没有索引，MySQL 不得不首先以第一条记录开始，然后读完整个表直到它找出相关的行。表越大，花费时间越多。对于一个有序字段，可以运用二分查找（Binary
Search），这就是为什么性能能得到本质上的提高。MYISAM 和 INNODB 都是用 B+Tree 作为索引结构

（主键，unique 都会默认的添加索引）

索引（Index）是帮助 MySQL 高效获取数据的数据结构。拍好序，可类比于字典

一般来说索引本身也很大，不可能全部存储在内存中，因此索引往往以索引文件的形式存储的磁盘上

## 16.2、索引的结构

我们平常所说的索引，如果没有特别指明，都是指 B 树(多路搜索树，并不一定是二叉的)结构组织的索引。

其中聚集索引，次要索引，覆盖索引，复合索引，前缀索引，唯一索引默认都是使用 B+树索引，统称索引。

当然，除了 B+树这种类型的索引之外，还有哈希索引(hash index)等。

1：B 树索引——Myisam

2：B+树索引——Innodb

**从 innodb 的索引结构分析，为什么索引的 key 长度不能太长？**

key 太长会导致一个页当中能够存放的 key 的数目变少，间接导致索引树的页数目变多，索引层次增加，从而影响整体查询变更的效率。

### mysql 数据结构

主要支持 Hash 和 B+数，Hash 对于范围查询时不支持的，Myisam 和 Innodb 都支持。

### B+数索引

B+树叶子节点中只有关键字和指向下一个节点的索引，记录只放在叶子节点中。(一次查询可能进行两次 i/o 操作)

Innodb 每张表都会有一个聚簇索引：每次进来都会有一个如果有主键就会根据主键生成索引，只会有一个聚簇索引，使用 B+数，

叶子节点之间使用单链表

3：对比

在内存有限的情况下，B+TREE 永远比 B-TREE 好。无限内存则后者方便

在 B-树中，越靠近根节点的记录查找时间越快，只要找到关键字即可确定记录的存在；

而 B+树中每个记录的查找时间基本是一样的，都需要从根节点走到叶子节点，而且在叶子节点中还要再比较关键字。

B+树的非叶子节点不存放实际的数据，这样每个节点可容纳的元素个数比 B-树多，树高比 B-树小，这样带来的好处是减少磁盘访问次数。

哈希索引：采用**哈希算法**，把键值换算成新的哈希值，检索时不需要类似 B+树那样从根节点到叶子节点逐级查找，只需一次哈希算法即可立刻定位到相应的位置，速度非常快。

没办法利用索引完成排序，以及 like 这样的模糊查询

**哈希索引也不支持多列联合索引的最左匹配规则**；

数据较多时，哈希所用的效率是非常差的。

**为什么选择 B+树，而不是其他的树？**

B+树的磁盘读写代价更低：B+树的查询效率更加稳定。由于 B+树的数据都存储在叶子结点中，分支结点均为索引，方便扫库，只需要扫一遍叶子结点即可。

B+树相比 B 树，新增叶子节点与非叶子节点关系，通过非叶子节点查询叶子节点获取相应的数据，所有相邻的叶子节点包含非叶子节点使用链表进行结合，叶子节点是顺序并且相邻节点有顺序引用关系。

B+树中，所有数据记录节点都是按照键值大小顺序存放在同一层叶子节点上，而非叶子节点上只存储 key 值信息，这样可以大大加大每个节点存储的 key 值数量，降低 B+树的高度。

二叉树，只有两个叉，树过高读写效率差。

### 回表

首先我们需要知道，我们建立几个索引，就会生成几棵 B+Tree，但是带有原始数据行的 B+Tree 只有一棵，另外一棵树上的叶子节点带的是主键值。

例如，我们通过主键建立了主键索引，然后在叶子节点上存放的是我们的数据

![](../../../4三千道藏/media/image-20200629094621998.png)

当我们创建了两个索引时，一个是主键，一个是 name，它还会在生成一棵 B+Tree，这棵树的叶子节点存放的是主键，当我们通过 name 进行查找的时候，会得到一个主键，然后在通过主键再去上面的这个主键 B+Tree 中进行查找，我们称这个操作为 ==**回表**==

![image-20200629094800800](../../../4三千道藏/media/image-20200629094800800.png)

当我们的 SQL 语句使用的是下面这种的时候，它会查找第一颗树，直接返回我们的数据

```mysql
select * from tb where id = 1
```

当我们使用下面这种查询的时候，它会先查找第二棵树得到我们的主键，然后拿着主键再去查询第一棵树

```mysql
select * from tb  where name = 'gang'
```

回表就是通过普通列的索引进行检索，然后再去主键列进行检索，这个操作就是回表

==但是我们在使用检索的时候，尽量避免回表，因为这会造成两次 B+Tree 的查询，假设一次 B+Tree 查询需要三次 IO 操作，那么查询两次 B+Tree 就需要六次 IO 操作。==

### 索引覆盖

我们看下面的两个 SQL 语句，看看它们的查询过程是一样的么？

```SQL
select * from tb where id = 1
select name from tb where name = zhou
```

答案是不一样的，首先我们看第二个语句，就是要输出的列中，就是我们的主键，当我们通过 name 建立的 B+Tree 进行查询的时候

![image-20200629094800800](../../../4三千道藏/media/image-20200629094800800-1611192365027.png)

我们可以直接找到我们的数据，并得到主键，但是因为我们要返回的就是 name，此时说明数据存在了，那么就直接把当前的 name 进行返回，而不需要通过主键再去主键 B+Tree 中进行查询。

这样一个不需要进行回表操作的过程，我们称为**索引覆盖**

## 16.3，分类

### 主键索引：

PRIMARY KEY(id)

ALTER TABLE customer

add PRIMARY KEY customer(customer_no);

Q：主键与索引的区别？

A：

1：主键是索引的一种，定义主键将自动创建主键索引，主键索引时唯一索引的特定类型。

2：一个表只能有一个主键，但是索引可以有多个。

### **唯一索引**

唯一索引 类似于普通索引，索引列的值必须唯一

唯一索引和主键索引的区别就是，唯一索引允许出现空值，而主键索引不能为空

```sql
create unique index index_name on table(column)
```

### **普通索引**

当我们需要建立索引的字段，既不是主键索引，也不是唯一索引

那么就可以创建一个普通索引

```sql
create index  index_name on table(column)
```

或者创建表时指定

```sql
create table(..., index index_name column)
```

### 单键索引

CREATE INDEX idx_customer_name ON customer(customer_name);

### **复合索引**

就可以通过组合 name 和 age 来建立一个组合索引，加快查询效率，建立成组合索引后，我的索引将包含两个 key 值

在多个字段上创建索引，遵循**最左匹配**原则

```sql
alter table t add index index_name(a,b,c);
```

#### 最左匹配原则

创建联合索引时，索引存储在叶子节点，叶子会根据最左边的进行排序，如果没有匹配上，后边也不再匹配，导致索引失效。

索引失效的情况：

- 不按顺序，跳过中间的索引
- 以%开头的 like
- where 带 or，mysiam 能用索引，innodb 不行，用 union 代替 or

高效：

```sql
select loc_id , loc_desc , region from location where loc_id = 10
union
select loc_id , loc_desc , region  from location where region = "melbourne"
```

低效：

```sql
select loc_id , loc desc , region from location where loc_id = 10 or region = "melbourne"
```

- 需要类型转换的
- 索引列有运算的
- 使用了函数的

### 哈希索引

概念

基于哈希的实现，只有精确匹配索引所有的列的查询才有效，在 mysql 中，只有 memory 的存储引擎显式支持哈希索引，哈希索引自身只需存储对应的 hash 值，索引索引的结构十分紧凑，这让哈希索引查找的速度非常快。

哈希索引的限制

- 哈希索引值包含哈希值和行指针，而不存储字段值。索引不能使用索引中的值来避免读取行
- 哈希索引数据并不是按照索引值顺序存储的，所以无法进行排序
- 哈希索引不支持部分列匹配查找，哈希索引是使用索引列的全部内容来计算哈希值
- 哈希索引支持等值比较查询，也不支持任何范围查询
- 访问哈希索引的数据非常快，除非有很多哈希冲突，当出现哈希冲突的时候，存储引擎必须遍历链表中的所有行指针，逐行进行比较，知道找到所有符合条件的行
- 哈希冲突比较多的话，维护的代价也会很高

### 前缀索引

列值太长，整列作为索引浪费空间，使用前缀索引。

```sql
alter table turl add key(url(7));
```



## 16.4，选择

MySQL 每次只使用一个索引，与其说 数据库查询只能用一个索引，倒不如说，和全表扫描比起来，去分析两个索引 B+树更耗费时间，所以 where A=a and B=b 这种查询使用（A，B）的组合索引最佳，B+树根据（A，B）来排序。

**Q：哪些情况需要创建索引？**

- 主键自动建立唯一索引

- 频繁作为查询条件的字段应该创建索引(where 后面的语句)

- 查询中与其它表关联的字段，外键关系建立索引

- 单键/组合索引的选择问题，who？(在高并发下倾向创建组合索引)

- 查询中排序的字段，排序字段若通过索引去访问将大大提高排序速度

- 查询中统计或者分组字段

**Q：哪些情况不要创建索引？**

- 表记录太少

- 经常增删改的表，经常修改的字段（建立索引修改索引代价较高）

Why:提高了查询速度，同时却会降低更新表的速度，如对表进行 INSERT、UPDATE 和 DELETE。

因为更新表时，MySQL 不仅要保存数据，还要保存一下索引文件

- Where 条件里用不到的字段不创建索引
- 数据重复且分布平均的表字段，因此应该只为最经常查询和最经常排序的数据列建立索引。
- 不能超过 16 个索引

注意，如果某个数据列包含许多重复的内容，为它建立索引就没有太大的实际效果。

字符串索引比整数型索引快，内存占用比整数型索引小。

## 5：Explain 性能分析

使用 EXPLAIN 关键字可以模拟优化器执行 SQL 查询语句，从而知道 MySQL 是

如何处理你的 SQL 语句的。分析你的查询语句或是表结构的性能瓶颈

一般用来查看索引是否起作用了，查询了多少行记录，

执行计划：

执行流程

#### 字段

**ID**

id 列的编号是 select 的序列号，有几个 select 就有几个 id，并且 id 的顺序是按 select 出现的顺序增长的。

id 值相同，从上往下顺序执行

表的执行顺序，因数量的个数改变而改变，数据量小的优先查询。

嵌套子查询时，先查内层，再查内层。

id 不同，id 越大越优先查询，2>1

**select_type**

查询的类型，主要是用于区分普通查询（simple）、联合查询、子查询等复杂的查询

simple：简单的 select 查询 ;

primary：查询中包含任何复杂的子部分，最外层查询则被标记为 primary=》复杂查询中最外层的 select

例

```sql
explain select * from (select * from t3 where id=3952602) a ;
```

subquery：在 select 或 where 列表中包含了子查询=》含在 select 中的子查询（不在 from 子句中） ;

simple：表示不需要 union 操作或者不包含子查询的简单 select 查询。有连接查询时，外层的查询为 simple，且只有一个。

primary：一个需要 union 操作或者含有子查询的 select，位于最外层的单位查询的 select_type 即为 primary。且只有一个。

subquery：除了 from 字句中包含的子查询外，其他地方出现的子查询都可能是 subquery

dependentsubquery：与 dependent union 类似，表示这个 subquery 的查询要受到外部表查询的影响。

derive：衍生查询，使用到了临时表，from 字句中出现的子查询，也叫做派生表，其他数据库中可能叫做内联视图或嵌套 select。

```sql
explain select cr.name from (select * from course where tid in (1,2)) cr;
```

union：union 连接的两个 select 查询，第一个查询是 dervied 派生表，除了第一个表外，第二个以后的表 select_type 都是 union

dependentunion：与 union\*\*一样，出现在 union 或 union all 语句中，但是这个查询要受到外部查询的影

unionresult\*：包含 union\*\*的结果集，在 union 和 union all 语句中,因为它不需要参与查询，所以 id 字段为 null。

**table**

表示 explain 的一行正在访问哪个表。

**type**

表示关联类型或访问类型，即 MySQL 决定如何查找表中的行。

访问类型，sql 查询优化中一个很重要的指标，结果值从好到坏依次是：

依次从最优到最差分别为：system >const > eq_ref > ref > fulltext > ref_or_null > index_merge >unique_subquery > index_subquery > range > index > ALL

从最好到最差的连接类型为 const、eq_reg、ref、range、indexhe 和 ALL

**一般来说，好的 sql 查询至少达到 range 级别，最好能达到 ref**,system 和 const 基本达不到。

system：只有一条数据的系统表，或：衍生表只有一条数据的主查询。新版的也查不到了

const：仅仅能查到一条数据，用于主键或唯一索引。

eq_ref：唯一性索引，对于每个索引建的查询，返回匹配唯一行数据（有且只有一个，不能多，不能 0）

```sql
select …… from …… where name = ……常见于唯一索引和主键索引
```

以上可预不可求。

ref：非唯一性索引，对于每个索引建的查询，返回匹配的所有行（0，多）

range：检索指定范围的行，where 后面是一个范围查询（between，in，> ,<，>=，但是 in 有时候会失效变成 all）

index：查询全部索引树中数据

```sql
explain select id from teacher
```

all：查询所有表的数据

**possible_keys**

显示查询可能使用哪些索引来查找。

**Key**

显示 mysql 实际采用哪个索引来优化对该表的访问。

果没有使用索引，则该列是 NULL。如果想强制 mysql 使用或忽视 possible_keys 列中的索引，在查询中使用 force index、ignore index。
查询中如果使用了覆盖索引，则该索引仅出现在 key 列表中

**Key_Len**

索引的长度，用于判断符合索引是否被完全使用，比如 a,b,c 都是 char(20),查询时 key_len 为 60，

如果索引字段可以为 null，则会使用一个字节用于标识。

如果是 varchar 可变长度，则会增加两个字节用于标识。

**ref**

作用：指明当前表所参考的字段，

```sql
select …… from where a.c = b.x
```

其中 b.x 可以是常量，此时就是 const

null 代表没有给列添加索引

这一列显示了在 key 列记录的索引中，表查找值所用到的列或常量，常见的有：const（常量），func，NULL，字段名（例：film.id）

**rows**

被优化查询的数据个数(实际通过索引查到的数据个数)

根据表统计信息及索引选用情况，大致估算出找到所需的记录所需要读取的行数

**Extra**

(1）：using filesort：性能消耗比较大，需要额外一次排序（查询）

排序：先查询，根据年龄排序，先查出年龄，再根据排序

```sql
explain select * from test02 where a1 = '' order by a2;
```

复合索引：不能跨列，（最左匹配原则）

对(a1,a2,a3)建立复合索引

```sql
select * from test02 where a1 = '' order by a2;---此时不会出现using filesort
select * from test02 where a1 = '' order by a3; -- 会出现，性能不如上一个好
```

（2）：using temporary ：性能耗损大，用到了临时表，一般出现在 group by 语句中

```sql
explain select a1 from test02 where a1 in ('1','2','3') group by a2;
```

这条语句会先根据 a1 查询出 a1 的记录，再查一遍 a2，放到临时表进行分组。

解析过程：

from on join where groupby having select distinct order by limit

（3）：using index ：性能提升，索引覆盖。不读取源文件，只从索引文件中查询。不需要回表查询。只要索引都在索引表中

```sql
select a1 from test where a1 = '1';
```

复合索引（a1，a2）

```sql
select a1,a2 from test where a1 = '' or a2 = '';
```

索引覆盖对 possible key 和 key 有影响，如果没有 where ，则索引只出现在 key 中，如果有 where ，则索引出现在 key 和 possible key 中

（4）using where；需要回表查询，

（5）impossible where ：where 子句永远为 false

```sql
select * from where a1 = '' and a1 = 'test';
```

**Case**

id，表（真实表），可能索引

index

#### 分析

索引的使用顺序和建立索引的顺序一致，但是可能自己没遵循，但是优化器会帮助你进行优化。

### 分析海量数据

存储过程，没有返回值，存储过程，有返回

模拟创建海量数据

（1）分析

```sql
show profiles;--默认是关闭的,会记录所有profiling打开之后的全部SQL查询语句所花费的时间
show variables like '%profiling%';
set profiling = on;--开启
show profiles;
```

（2）SQL 诊断：上述缺点：不够精确，不能分别显示 IO 等，可以使用进行 SQL 诊断

```sql
show profile all for query 2;--2代表profiles中的SQL序号
show profile cpu,blockio for query;--显示cpu占用时间和IO响应时间
```

（3）全局查询日志：记录开启后，全部 SQL 语句。

```sql
show variables like '%general_log%';
set global general_log = 1;--开启全局日志
```

### 索引下推

在说索引下推的时候，我们首先在举两个例子

```sql
select * from tb1 where name = ? and age = ?
```

在 mysq 5.6 之前，会先根据 name 去存储引擎中拿到所有的数据，然后在 server 层对 age 进行数据过滤

在 mysql5.6 之后，根据 name 和 age 两个列的值去获取数据，直到把数据返回。

通过对比能够发现，第一个的效率低，第二个的效率高，因为整体的 IO 量少了，原来是把数据查询出来，在 server 层进行筛选，而现在在存储引擎层面进行筛选，然后返回结果。我们把这个过程就称为 **索引下推**

### 隐式转换

情况： 

项目中有一个表A的goodsid是varchar类型，另一个表B的goodsid是int类型，同时这两个表的goodsid都是主键。在获取表B的goodsid后直接在表A中查询，大数据量下超时严重

表B的goodsid是int类型，使用int类型在表A中查询时会发生隐式转换，此时表A的goodsid字段因为隐式转换会扫描全表，造成字段的索引阻塞。

原理：

1）如果表定义的是varchar字段，传入的是int型数字，则会发生隐式转换

2）表定义的是int字段，传入的是varchar数字字符串，不会发生隐式转换，如果在与数字字符串比较大小并且数字字符串还超过int定义的长度（会以字符串类型比较'$'）会隐式转换

3）隐式转换会扫描全表，造成字段的索引的阻塞。

解决：

将ID类型全部



## 16.2、索引的应用

##### 16.2.1、创建索引

如果未使用索引，我们查询 工资大于 1500 的会执行全表扫描

![](../../../4三千道藏/media/media/76b85427b0a7c2736062c47b5bbb821b.png)

**什么时候需要给字段添加索引：**

**-表中该字段中的数据量庞大**

**-经常被检索，经常出现在 where 子句中的字段**

**-经常被 DML 操作的字段不建议添加索引**

**索引等同于一本书的目录**

**主键会自动添加索引，所以尽量根据主键查询效率较高。**

如经常根据 sal 进行查询，并且遇到了性能瓶颈，首先查看程序是否存算法问题，再考虑对 sal 建立索引，建立索引如下：

1、create unique index 索引名 on 表名(列名);

create unique index u_ename on emp(ename);  
2、alter table 表名 add unique index 索引名 (列名);

create index test_index on emp (sal);

查看索引

```sql
show index from 表名;
```

##### 16.2.3、使用索引

注意一定不可以用 select \* … 可以看到 type!=all 了，说明使用了索引

explain select sal from emp where sal \> 1500;

条件中的 sal 使用了索引

![](../../../4三千道藏/media/aa6ee6d7d6d4be73a68fc141deaf7a36.png)

如下图：假如我们要查找 sal 大于 1500 的所有行，那么可以扫描索引，索引时排序的，结果得出 7 行，我们知道不会再有匹配的记录，可以退出了。
如果查找一个值，它在索引表中某个中间点以前不会出现，那么也有找到其第一个匹配索引项的定位算法，而不用进行表的顺序扫描（如二分查找法）。
这样，可以快速定位到第一个匹配的值，以节省大量搜索时间。数据库利用了各种各样的快速定位索引值的技术，通常这些技术都属于 DBA 的工作。

##### 16.2.4、删除索引

DROP INDEX index_name ON talbe_name

ALTER TABLE table_name DROP INDEX index_name

ALTER TABLE table_name DROP PRIMARY KEY

其中，前两条语句是等价的，删除掉 table_name 中的索引 index_name。 第 3 条语句只在删除 PRIMARY KEY 索引时使用，因为一个表只可能有一个 PRIMARY KEY 索引，

mysql\> ALTER TABLE EMP DROP INDEX test_index; 删除后就不再使用索引了，查询会执行全表扫描。

![media1/da66a0e605b6d983bbebee622f5a45c4.png](../../../4三千道藏/media/da66a0e605b6d983bbebee622f5a45c4.png)

## 7：索引匹配

## 8：聚簇索引与非聚簇索引

- 聚簇索引：将数据存储与索引放到一块，索引结构的叶子节点保存了行数据

聚簇索引就是按每张表的主键构造一棵 B+树，同时叶子节点中存放的就是整张表的行记录数据，也将聚簇索引的叶子节点称为数据也，这个特性就决定了索引组织表中的数据也是索引的一部分。

==一句话来说：将索引和数据放在一起的，就称为聚簇索引==

- 非聚簇索引：将数据与索引分开，索引结构的叶子节点指向了数据对应的位置

在 InnoDB 中，在聚簇索引之上创建的索引被称为辅助索引，非聚簇索引都是辅助索引，像复合索引，前缀索引，唯一索引。辅助索引叶子节点存储不再是行的物理位置，而是主键值，辅助索引访问数据总是需要二次查找，这个就被称为 回表操作

![image-20200723105915972](../../../4三千道藏/media/image-20200723105915972.png)

InnoDB 使用的是聚簇索引，将主键组织到一棵 B+树中，而行数据就储存在叶子节点上，若使用"where id = 14"这样的条件查找主键，则按照 B+树的检索算法即可查找到对应的叶节点，之后获得行数据。

若对 Name 列进行条件搜索，则需要两个步骤：第一步在辅助索引 B+树中检索 Name，到达其叶子节点获取对应的主键。第二步使用主键在主索引 B+树种再执行一次 B+树检索操作，最终到达叶子节点即可获取整行数据。（重点在于通过其他键需要建立辅助索引）

**聚簇索引具有唯一性**，由于聚簇索引是将数据跟索引结构放到一块，因此一个表仅有一个聚簇索引。

**表中行的物理顺序和索引中行的物理顺序是相同的**，**在创建任何非聚簇索引之前创建聚簇索引**，这是因为聚簇索引改变了表中行的物理顺序，数据行 按照一定的顺序排列，并且自动维护这个顺序；

**聚簇索引默认是主键**，如果表中没有定义主键，InnoDB 会选择一个**唯一且非空的索引**代替。如果没有这样的索引，InnoDB 会**隐式定义一个主键（类似 oracle 中的 RowId）**来作为聚簇索引。如果已经设置了主键为聚簇索引又希望再单独设置聚簇索引，必须先删除主键，然后添加我们想要的聚簇索引，最后恢复设置主键即可。

### 聚簇索引

优点：

- 数据访问更快，因为聚簇索引将索引和数据保存在一个 B+树中，因此从聚簇索引中获取数据比非聚簇索引更快
- 聚簇索引对主键的排序和范围查找速度非常快

缺点：

- 插入速度严重依赖于排序，按照主键的顺序插入是最快的方式，否者会出现页分裂，严重影响性能。因此，对于 InnoDB 表，我们一般都会定义一个自增的 ID 列作为主键
- 更新主键的代价很高，因为将会导致被更新的行移动，因此，对于 InnoDB 表，我们一般定义主键不可更新
- 二级索引访问需要两次索引查找，第一次找到主键值，第二次 根据主键值查找行数据，一般我们需要尽量避免出现索引的二次查找，这个时候，用到的就是**索引的覆盖**

**每次使用辅助索引检索都要经过两次 B+树查找，**看上去聚簇索引的效率明显要低于非聚簇索引，这不是多此一举吗？聚簇索引的优势在哪？

1.由于行数据和聚簇索引的叶子节点存储在一起，同一页中会有多条行数据，访问同一数据页不同行记录时，已经把页加载到了 Buffer 中（缓存器），再次访问时，会在内存中完成访问，不必访问磁盘。这样主键和行数据是一起被载入内存的，找到叶子节点就可以立刻将行数据返回了，如果按照主键 Id 来组织数据，获得数据更快。

2.辅助索引的叶子节点，存储主键值，而不是数据的存放地址。好处是当行数据放生变化时，索引树的节点也需要分裂变化；或者是我们需要查找的数据，在上一次 IO 读写的缓存中没有，需要发生一次新的 IO 操作时，可以避免对辅助索引的维护工作，只需要维护聚簇索引树就好了。另一个好处是，因为辅助索引存放的是主键值，减少了辅助索引占用的存储空间大小。

注：我们知道一次 io 读写，可以获取到 16K 大小的资源，我们称之为读取到的数据区域为 Page。而我们的 B 树，B+树的索引结构，叶子节点上存放好多个关键字（索引值）和对应的数据，都会在一次 IO 操作中被读取到缓存中，所以在访问同一个页中的不同记录时，会在内存里操作，而不用再次进行 IO 操作了。除非发生了页的分裂，即要查询的行数据不在上次 IO 操作的换村里，才会触发新的 IO 操作。

3.因为 MyISAM 的主索引并非聚簇索引，那么他的数据的物理地址必然是凌乱的，拿到这些物理地址，按照合适的算法进行 I/O 读取，于是开始不停的寻道不停的旋转。聚簇索引则只需一次 I/O。（强烈的对比）

4.不过，如果涉及到大数据量的排序、全表扫描、count 之类的操作的话，还是 MyISAM 占优势些，因为索引所占空间小，这些操作是需要在内存中完成的。

### **聚簇索引需要注意的地方**

当使用主键为聚簇索引时，主键最好不要使用 uuid，因为 uuid 的值太过离散，不适合排序且可能出线新增加记录的 uuid，会插入在索引树中间的位置，导致索引树调整复杂度变大，消耗更多的时间和资源。

建议使用 int 类型的自增，方便排序并且默认会在索引树的末尾增加主键值，对索引树的结构影响最小。而且，主键值占用的存储空间越大，辅助索引中保存的主键值也会跟着变大，占用存储空间，也会影响到 IO 操作读取到的数据量。

**为什么主键通常建议使用自增 id**

**聚簇索引的数据的物理存放顺序与索引顺序是一致的**，即：**只要索引是相邻的，那么对应的数据一定也是相邻地存放在磁盘上的**。如果主键不是自增 id，那么可以想 象，它会干些什么，不断地调整数据的物理地址、分页，当然也有其他一些措施来减少这些操作，但却无法彻底避免。但，如果是自增的，那就简单了，它只需要一 页一页地写，索引结构相对紧凑，磁盘碎片少，效率也高。

### 非聚簇索引

非聚簇索引也被称为辅助索引，辅助索引在我们访问数据的时候总是需要两次查找。辅助索引叶子节点存储的不再是行的物理位置，而是主键值。通过辅助索引首先找到主键值，然后在通过主键值找到数据行的数据页，在通过数据页中的 Page Directory 找到数据行。

InnoDB 辅助索引的叶子节点并不包含行记录的全部数据，叶子节点除了包含键值外，还包含了行数据的聚簇索引建。辅助索引的存在不影响数据在聚簇索引中的组织，所以一张表可以有多个辅助索引。在 InnoDB 中有时也称为辅助索引为二级索引

![image-20200629113413737](../../../4三千道藏/media/image-20200629113413737.png)

MyISAM 使用的是非聚簇索引，**非聚簇索引的两棵 B+树看上去没什么不同**，节点的结构完全一致只是存储的内容不同而已，主键索引 B+树的节点存储了主键，辅助键索引 B+树存储了辅助键。表数据存储在独立的地方，这两颗 B+树的叶子节点都使用一个地址指向真正的表数据，对于表数据来说，这两个键没有任何差别。由于**索引树是独立的，通过辅助键检索无需访问主键的索引树**。

![image-20200723110258929](../../../4三千道藏/media/image-20200723110258929.png)

# 第七章：优化

## 语句优化

### 减少查询字段

1：like减少

```sql
--原本
select t.* from ic_website t where t.url like '%72511%' ;
--百万执行9S
--优化
select * from ic_website t1 INNER JOIN(select t.id,t.url from ic_website t where t.url like '%72511%' ) t2 on t1.id = t2.id ;
--百万执行0.9s
```

2：分页limit减少

### 增加冗余字段

增加冗余字段，减少多张表的关联查询；

### 分解关联查询

缓存效率高，分解后，单个表改变可能少，命中率就高了。

减少数据库锁竞争

微服务化友好，易于做数据库拆分

减少冗余查询，减少传输



1：尽量不要使用 NULL，应该在 Service 层优化处理。

2：查询条件中不要使用函数，计算

3：尽量不要使用 NOT 等负向查询，因为这样会发生全表的遍历。

4：OR 改成 IN 或者使用 Union



4：大于小于，IN，OR，between

```sql
SELECT * FROM tin where c1 >= 100 and c1 <= 104;
SELECT * FROM tin where c1 bewteen 100 and 104;
SELECT * FROM tin where c1 in (100, 101, 102, 103, 104);
SELECT * FROM tin where c1 = 100 or c1 = 101 or c1 = 102 or c1 = 103 or c1 = 104;
```

语句 1 应该是最少的，其次是 IN，最差的就是 OR

5：小表驱动大表

6：表连接最好在 where 条件以前。

7：from 子句组装来自不同数据源的数据；（from 后面的表关联，是自右向左解析的，即在写 SQL 的时候，尽量把数据量大的表放在最右边来进行关联）

对查询进行优化，应尽量避免全表扫描

（1）Where 语句

- 避免在 WHERE 子句中使用 in，not in，or 或者 having；
- 可以使用 exist 和 not exist 代替 in 和 not in；对连续数值可以使用 between；
- 可以使用表链接代替 exist；
- Having 可以用 where 代替，如果无法代替可以分两步处理。
- 应尽量避免在 where 子句中对字段进行函数操作；
- 尽量避免在 where 子句中对索引字段进行计算操作；
- 应尽量避免在 where 子句中使用 != 或 <> 操作符；
- 应尽量避免在 where 子句中对字段进行 null 值判断；
- 应尽量避免在 where 子句中使用 or 来连接条件；
- 否则将导致引擎放弃使用索引而进行全表扫描

（2）Select 语句

- 尽量不要使用 select \* from table 这种方式；把要查询的具体字段列出来，不要返回任何用不到的字段；
- 尽可能的使用 varchar/nvarchar 代替 char/nchar ，因为首先变长字段存储空间小，可以节省存储空间；

（3）连接语句

- UNION 会将各查询子集的记录做比较，自动去掉重复记录，故比起 UNION ALL 的速度，UNION 的速度会慢很多。一般来说，如果使用 UNION ALL 能满足要求的话，尽量使用 UNION ALL。

（4）Count (\*)和 Count(1)以及 Count(column)的区别

- 一般情况，Select Count (\*)和 Select Count(1)返回结果一样；
- 假如表没有主键(Primary key)，那么 count(1)比 count(\*)快；
- 如果有主键，那主键作为 count 的条件时 count(主键)最快；
- 如果你的表只有一个字段，那 count(\*)最快；
- count(\*) 跟 count(1) 的结果一样，都包括对 NULL 的统计，而 count(column) 不包括 NULL 的统计

（5）查询的模糊匹配

- 尽量避免在一个复杂查询里面使用 LIKE '%parm1%' ，百分号会导致相关列的索引无法使用，最好不要用。

（6）复杂操作

- 部分 UPDATE、SELECT 语句 写得很复杂（经常嵌套多级子查询），可以适当拆成几步，先生成一些临时表，再进行关联操作。
- 尽量使用数字型字段，若只含数值信息的字段尽量不要设计为字符型，这会降低查询和连接的性能，并会增加存储开销。这是因为引擎在处理查询和连接时会逐个比较字符串中每一个字符，而对于数字型而言只需要比较一次就够了。

（7）order by

处理：1：根据 where 条件和统计信息生成执行计划，得到数据。 二：当执行处理数据（order by）时，数据库会先查看第一步的执行计划，看 order by 的字段是否在执行计划中利用了索引。如果是，则可以利用索引顺序而直接取得已经排好序的数据。三：返回排序后的数据。

排序按索引顺序排，（a,b,c)无法复用已经创建好的索引。

using filesort 有两种算法：双路排序和单路排序（根据 IO 的次数）

MYSQL4.1 之后默认使用单路排序，只读取一次（全部字段），在 Buffer 中进行排序。但是它有可能不是真的单次 IO，如果数据量特别大，Buffer 是放不开的。调整 Buffer 大小：set max_leng_for_sort_data

提高 order by 的策略：

（1）选择单路，双路；

（2）调整 buffer 的容量大小，

（3）避免 select \*

（4）保证全升或全降

1：使用索引

建立索引后还是使用正常的 sql 语句

全职匹配

最左匹配

2：连接查询优化

left join 时，选择小表作为驱动表，大表作为被驱动表。 left join 时一定是左边是驱动表，右边是被驱动表

3：order by

4：去重优化

select **distinct** kcdz form t_mall_sku where id in( 3,4,5,6,8 ) 使用 distinct
关键字去重消耗性能

select kcdz form t_mall_sku where id in( 3,4,5,6,8 ) **group by kcdz**

能够利用到索引\*\*

### 避免全表扫描

### Join优化

mysql的join语句连接表使用的是nested-loop join算法；这个过程类似于嵌套循环，简单来说，就是遍历驱动表，每读出一行数据，取出连接字段到被驱动表（内层表）里查找满足条件的行，组成结果行；

给被驱动表的join字段建立索引；

小结果集驱动大结果集；如果无法判断哪个是大表哪个是小表，可以用inner join连接，MYSQL会自动选择小表去驱动达标；

### Union优化

MySQL处理union的策略是先创建临时表，然后将各个查询结果填充到临时表中最后再来做查询，很多优化策略在union查询中都会失效，因为它无法利用索引

最好手工将where、limit等子句下推到union的各个子查询中，以便优化器可以充分利用这些条件进行优化]

此外，除非确实需要服务器去重，一定要使用union all，如果不加all关键字，MySQL会给临时表加上distinct选项，这会导致对整个临时表做唯一性检查，代价很高

## 索引优化

### 创建

1：组合索引与单独索引

`A=a AND B=b ` 应该使用复合索引，单独索引只有第一个起作用，第二个是不起作用的。而 `A=a OR B=b` 此时复合索引时不起作用的，应该使用单独索引，使两个同时起作用。

2：索引要有区分度，性别这种把一张表分成两部分完全没有必要。

3：采用自增主键，并且主键应该减少更新，减少 B+树的频繁合并和分裂。

4：频繁更改的字段上应该删掉索引。

### 索引失效

一般情况对于左外连接给左表加索引，左表使用频繁，右外连接给右表加索引。

避免索引失效：

（1）：复合索引：不要跨列使用，尽量使用全索引匹配。

（2）：不要在索引上进行任何操作，否则索引失效。

（3）：复合索引不能使用不等于或`is null ` ,否则自身以及右侧所有索引全部失效。

（4）：复合索引中如果有>,则自身和右侧索引失效

优化时 SQL 优化器会影响我们的优化，导致一些概率性的出现。

补救：使用索引覆盖

(5)：like 以`%` 开头，失效

例如：

如果有索引 （sex，username）当查询name时无法使用索引。可以这样写：

```sql
select * from t where t.sex in (0,1) and t.username = "XXX";
```

（6）!= 优化

union



2：exist 和 in

如果主查询的数据集大，则使用 In。如果子查询的数据量大，则使用 exist

```sql
select …… from table where exist (子查询);
select …… from table where 字段 in (子查询);
```

## 表库优化

2：优化数据库结构

将字段多的表分解成多个表，增加中间表

### 慢查询日志

默认关闭，开发调优时打开日志，部署时关闭。

检查是否开启了慢查询日志

```sql
show variables like '%slow_query_log%';
```

开启慢查询日志

```sql
-- 临时开启，退出关闭服务即关闭
set global slow_query_log = 1;

--永久开启，一般不用
/etc/my.cnf中追加配置
slow_query_log = 1
slow_query_log_file= /var/lib/mysql/localhost-slow.log
```

慢查询默认阈值为 10 秒，修改慢查询阀值

```sql
-- 设置临时阈值
set global long_query_time = 5;

--永久开启，一般不用
/etc/my.cnf中追加配置
long_query_time = 3;
```

查询超过慢查询阈值的命令

```sql
show global status like '%slow_querise%';--只显示有几条，具体是哪条查看日志文件
```

通过工具查看

mysqldumpslow – help

## 工具

https://mp.weixin.qq.com/s/2e6_J5PvxhB59tschGO4yA

# 第七章、视图

### 17.1、什么是视图

- 视图是一种根据查询（也就是 SELECT 表达式）定义的数据库对象，用于获取想要看到和使用的局部数据。

- 视图有时也被成为“虚拟表”。

- 视图可以被用来从常规表（称为“基表”）或其他视图中查询数据。

- 相对于从基表中直接获取数据，视图有以下好处：

  - 访问数据变得简单

  - 可被用来对不同用户显示不同的表的内容

用来协助适配表的结构以适应前端现有的应用程序

视图作用：

- 提高检索效率

- 隐藏表的实现细节【面向视图检索】

![](../../../4三千道藏/media/664338c444a37bb9287afdb2050c0dc8.png)

### 17.2、创建视图

如下示例：查询员工的姓名，部门，工资入职信息等信息。

| select ename,dname,sal,hiredate,e.deptno from emp e,dept d where e.deptno = e.deptno and e.deptno = 10;

为什么使用视图？因为需求决定以上语句需要在多个地方使用，如果频繁的拷贝以上代码，会给维护带来成本，视图可以解决这个问题

| create view v_dept_emp as select ename,dname,sal,hiredate,e.deptno from emp e,dept d where e.deptno = e.deptno and e.deptno = 10;                                                                                                        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| create view v_dept_avg_sal_grade as select a.deptno, a.avg_sal, b.grade from (select deptno, avg(sal) avg_sal from emp group by deptno) a, salgrade b where a.avg_sal between b.losal and b.hisal; /\*注意 mysql 不支持子查询创建视图\*/ |

### 17.3、修改视图

| alter view v_dept_emp as select ename,dname,sal,hiredate,e.deptno from e mp e,dept d where e.deptno = 20;

### 17.4、删除视图

| drop view if exists v_dept_emp; |

# 第八章：存储过程

优点：

- 存储过程可封装，并隐藏复杂的商业逻辑。

- 存储过程可以回传值，并可以接受参数。

- 存储过程无法使用 SELECT 指令来运行，因为它是子程序，与查看表，数据表或用户定义函数不同。

- 存储过程可以用在数据检验，强制实行商业逻辑等。

  缺点

- 存储过程，往往定制化于特定的数据库上，因为支持的编程语言不同。当切换到其他厂商的数据库系统时，需要重写原有的存储过程。

- 存储过程的性能调校与撰写，受限于各种数据库系统。

创建的存储过程保存在数据库的数据字典中。

# 第九章、DBA 命令

## 新建用户

(1)

```sql
CREATE USER username IDENTIFIED BY 'password';
//修改用户密码
alter USER username identified by 'newpassword'
```

说明:

username——你将创建的用户名,

password——该用户的登陆密码,密码可以为空,如果为空则该用户可以不需要密码登陆服务器.

例如： create user p361 identified by '123';

(2)可以登录但是只可以看见一个库 information_schema

命令详解

```sql
grant all privileges on dbname.tbname to 'username'@'login ip' identified by 'password' with grant option;
```

dbname=\*表示所有[数据库](http://www.2cto.com/database/)

tbname=\*表示所有表

login ip=%表示任何 ip

password 为空，表示不需要密码即可登录

with grant option; 表示该用户还可以授权给其他用户

细粒度授权 首先以 root 用户进入 mysql，然后键入命令：

grant select,insert,update,delete on \*.\* to p361 \@localhost Identified by "123";

如果希望该用户能够在任何机器上登陆 mysql，则将 localhost 改为 "%" 。

粗粒度授权 我们测试用户一般使用该命令授权，

GRANT ALL PRIVILEGES ON \*.\* TO 'p361'\@'%' Identified by "123";

注意:用以上命令授权的用户不能给其它用户授权,如果想让该用户可以授权,用以下命令:

GRANT ALL PRIVILEGES ON \*.\* TO 'p361'\@'%' Identified by "123" WITH GRANT OPTION;

privileges 包括： alter：修改数据库的表 create：创建新的数据库或表 delete：删除表数据 drop：删除数据库/表 index：创建/删除索引 insert：添加表数据 select：查询表数据 update：更新表数据 all：允许任何操作 usage：只允许登录

## 授权

```sql
//授予某一项权利
grant create view to 用户名

//撤销角色/权限
revoke 角色|权限 from 用户名

//查看自身有哪些角色
select * from user_role_privs;

//查看自身的角色和权限
select * from role_sys_privs;

//修改用户处于锁定（非锁定）状态，锁定状态是不能登录的
alter user 用户名 account lock|unlock;
```

## 回收权限

命令详解

revoke privileges on dbname[.tbname] from username; revoke all privileges on \*.\* from p361; use mysql select \* from user

进入 mysql 库中 修改密码; update user set password = password('qwe') where user = 'p646';

刷新权限; flush privileges

## 导出导入

**导出**

导出整个数据库

在 windows 的 dos 命令窗口中执行：

mysqldump bjpowernode\>D:\\bjpowernode.sql -uroot -p123

导出指定库下的指定表

在 windows 的 dos 命令窗口中执行：mysqldump bjpowernode emp\> D:\\ bjpowernode.sql
-uroot –p123

**导入**

登录 MYSQL 数据库管理系统之后执行：source D:\\ bjpowernode.sql

## 备份

完全备份

```sql
## mysql5.7
## 备份命令
innobackupex --user=root --password=‘1234' /xtrabackup/full

## 备份完成查看
ls /xtrabackup/full

## mysql8
xtrabackup --defaults-file=/etc/my.cnf --host=localhost --user=root --password=http://Qf123.com --port=3306 --backup --target-dir=/data/backup/
或者使用参数--datadir替换掉参数--defaults-file.

```

恢复

```sql
## mysql5.7
# 停止
systemctrl stop mysqld
# 模拟数据丢失
rm -f /var/lib/mysql/*
# 生成回滚日志
innobackupex --apply-log /xtrabackup/full/2017-08-01_00-00-18/
# 恢复文件
innobackupex --copy-back /xtrabackup/full/2017-08-01_00-00-18/
# 重新赋权
chown -R mysql.mysql /var/lib/mysql
# 启动
systemctl start mysqld

## mysql8

```

增量备份

需要在完全备份的基础上

```sql
innobackupex --user=root --password='1234' --incremental /xtrabackup/ --incremental-basedir=/xtrabackup/2017-09-01_00-00-04
```

恢复

```sql
# 生成回滚日志
innobackupex --apply-log --redo-only /xtrabackup/2017-09-01_00-00-04
innobackupex --apply-log --redo-only /xtrabackup/2017-09-01_00-00-04 --incremental-dir=/xtrabackup/2017-09-02_00-00-26

# 恢复文件
innobackupex --copy-back /xtrabackup/2017-09-01_00-00-06
# 赋权
chown -R mysql.mysql /var/lib/mysql

```







# 第十章：MySQL 锁机制

只有通过索引进行检索的时候才会使用行级锁，如果不是通过索引进行检索就会升级成表锁。

行锁是为了最大并发化所提供的一种锁，封锁某一行数据。我知道的 mysql 行锁有三种，就间隙锁使用场景，我分成了`唯一索引`和`非唯一索引`两种情况。`记住所有的for update都是当前读并且加上行锁，跟快照读不一样，`

（1）按对数据操作：

读锁（共享锁）：多个读操作可以同时进行，互不干扰

写锁（互斥锁）：如果当前写操作没有完毕，则无法进行其他读操作和写操作。

（2）按粒度分：表锁和行锁

表锁：

偏小 myisam 存储引擎，开销小，无死锁，容易发生锁冲突，并发度低。

lock table 表名字 1 read(write)，表名字 2 read(write)，其它

行锁

偏向 innodb,开销大，支持事务

总的来说，Innodb 共有其中类型的锁

锁是计算机协调多个进程或线程并发访问某一资源的机制。锁保证数据并发访问的一致性、有效性；锁冲突也是影响数据库并发访问性能的一个重要因素。锁是Mysql在服务器层和存储引擎层的的并发控制。

加锁是消耗资源的，锁的各种操作，包括获得锁、检测锁是否是否已解除、释放锁等。

## **锁机制**

## **共享锁与排他锁**

-   共享锁（读锁）：其他事务可以读，但不能写。
    
-   排他锁（写锁） ：其他事务不能读取，也不能写。
    

## **粒度锁**

MySQL 不同的存储引擎支持不同的锁机制，所有的存储引擎都以自己的方式显现了锁机制，服务器层完全不了解存储引擎中的锁实现：

-   MyISAM 和 MEMORY 存储引擎采用的是表级锁（table-level locking）
    
-   BDB 存储引擎采用的是页面锁（page-level locking），但也支持表级锁
    
-   InnoDB 存储引擎既支持行级锁（row-level locking），也支持表级锁，但默认情况下是采用行级锁。
    

默认情况下，表锁和行锁都是自动获得的， 不需要额外的命令。

但是在有的情况下， 用户需要明确地进行锁表或者进行事务的控制， 以便确保整个事务的完整性，这样就需要使用事务控制和锁定语句来完成。

## **不同粒度锁的比较：**

-   表级锁：开销小，加锁快；不会出现死锁；锁定粒度大，发生锁冲突的概率最高，并发度最低。
    
-   这些存储引擎通过总是一次性同时获取所有需要的锁以及总是按相同的顺序获取表锁来避免死锁。
    
-   表级锁更适合于以查询为主，并发用户少，只有少量按索引条件更新数据的应用，如Web 应用
    
-   行级锁：开销大，加锁慢；会出现死锁；锁定粒度最小，发生锁冲突的概率最低，并发度也最高。
    
-   最大程度的支持并发，同时也带来了最大的锁开销。
    
-   在 InnoDB 中，除单个 SQL 组成的事务外， 锁是逐步获得的，这就决定了在 InnoDB 中发生死锁是可能的。
    
-   行级锁只在存储引擎层实现，而Mysql服务器层没有实现。 行级锁更适合于有大量按索引条件并发更新少量不同数据，同时又有并发查询的应用，如一些在线事务处理（OLTP）系统
    
-   页面锁：开销和加锁时间界于表锁和行锁之间；会出现死锁；锁定粒度界于表锁和行锁之间，并发度一般。
    

## **MyISAM 表锁**

## **MyISAM表级锁模式：**

-   表共享读锁 （Table Read Lock）：不会阻塞其他用户对同一表的读请求，但会阻塞对同一表的写请求；
    
-   表独占写锁 （Table Write Lock）：会阻塞其他用户对同一表的读和写操作；
    

MyISAM 表的读操作与写操作之间，以及写操作之间是串行的。当一个线程获得对一个表的写锁后， 只有持有锁的线程可以对表进行更新操作。 其他线程的读、 写操作都会等待，直到锁被释放为止。

默认情况下，写锁比读锁具有更高的优先级：当一个锁释放时，这个锁会优先给写锁队列中等候的获取锁请求，然后再给读锁队列中等候的获取锁请求。 （This ensures that updates to a table are not “starved” even when there is heavy SELECT activity for the table. However, if there are many updates for a table, SELECT statements wait until there are no more updates.）。

这也正是 MyISAM 表不太适合于有大量更新操作和查询操作应用的原因，因为，大量的更新操作会造成查询操作很难获得读锁，从而可能永远阻塞。同时，一些需要长时间运行的查询操作，也会使写线程“饿死” ，应用中应尽量避免出现长时间运行的查询操作（在可能的情况下可以通过使用中间表等措施对SQL语句做一定的“分解” ，使每一步查询都能在较短时间完成，从而减少锁冲突。如果复杂查询不可避免，应尽量安排在数据库空闲时段执行，比如一些定期统计可以安排在夜间执行）。

可以设置改变读锁和写锁的优先级：

-   通过指定启动参数low-priority-updates，使MyISAM引擎默认给予读请求以优先的权利。
    
-   通过执行命令SET LOW_PRIORITY_UPDATES=1，使该连接发出的更新请求优先级降低。
    
-   通过指定INSERT、UPDATE、DELETE语句的LOW_PRIORITY属性，降低该语句的优先级。
    
-   给系统参数max_write_lock_count设置一个合适的值，当一个表的读锁达到这个值后，MySQL就暂时将写请求的优先级降低，给读进程一定获得锁的机会。
    

## **MyISAM加表锁方法：**

MyISAM 在执行查询语句（SELECT）前，会自动给涉及的表加读锁，在执行更新操作 （UPDATE、DELETE、INSERT 等）前，会自动给涉及的表加写锁，这个过程并不需要用户干预，因此，用户一般不需要直接用 LOCK TABLE 命令给 MyISAM 表显式加锁。

在自动加锁的情况下，MyISAM 总是一次获得 SQL 语句所需要的全部锁，这也正是 MyISAM 表不会出现死锁（Deadlock Free）的原因。

MyISAM存储引擎支持并发插入，以减少给定表的读和写操作之间的争用：

如果MyISAM表在数据文件中间没有空闲块，则行始终插入数据文件的末尾。 在这种情况下，你可以自由混合并发使用MyISAM表的INSERT和SELECT语句而不需要加锁——你可以在其他线程进行读操作的时候，同时将行插入到MyISAM表中。 文件中间的空闲块可能是从表格中间删除或更新的行而产生的。 如果文件中间有空闲快，则并发插入会被禁用，但是当所有空闲块都填充有新数据时，它又会自动重新启用。 要控制此行为，可以使用MySQL的concurrent_insert系统变量。

如果你使用LOCK TABLES显式获取表锁，则可以请求READ LOCAL锁而不是READ锁，以便在锁定表时，其他会话可以使用并发插入。

-   当concurrent_insert设置为0时，不允许并发插入。
    
-   当concurrent_insert设置为1时，如果MyISAM表中没有空洞（即表的中间没有被删除的行），MyISAM允许在一个线程读表的同时，另一个线程从表尾插入记录。这也是MySQL的默认设置。
    
-   当concurrent_insert设置为2时，无论MyISAM表中有没有空洞，都允许在表尾并发插入记录。
    

## **查询表级锁争用情况：**

可以通过检查 table_locks_waited 和 table_locks_immediate 状态变量来分析系统上的表锁的争夺，如果 Table_locks_waited 的值比较高，则说明存在着较严重的表级锁争用情况：

 mysql> SHOW STATUS LIKE 'Table%';  
 +-----------------------+---------+  
 | Variable_name | Value |  
 +-----------------------+---------+  
 | Table_locks_immediate | 1151552 |  
 | Table_locks_waited | 15324 |  
 +-----------------------+---------+

## **InnoDB行级锁和表级锁**

## **InnoDB锁模式：**

InnoDB 实现了以下两种类型的**行锁**：

-   共享锁（S）：允许一个事务去读一行，阻止其他事务获得相同数据集的排他锁。
    
-   排他锁（X）：允许获得排他锁的事务更新数据，阻止其他事务取得相同数据集的共享读锁和排他写锁。
    

为了允许行锁和表锁共存，实现多粒度锁机制，InnoDB 还有两种内部使用的意向锁（Intention Locks），这两种意向锁都是**表锁**：

-   意向共享锁（IS）：事务打算给数据行加行共享锁，事务在给一个数据行加共享锁前必须先取得该表的 IS 锁。
    
-   意向排他锁（IX）：事务打算给数据行加行排他锁，事务在给一个数据行加排他锁前必须先取得该表的 IX 锁。
    

**锁模式的兼容情况：**

![](https://pic4.zhimg.com/v2-37761612ead11ddc3762a4c20ddab3f3_b.jpg#id=lmjIQ&originHeight=274&originWidth=815&originalType=binary&ratio=1&status=done&style=none)

（如果一个事务请求的锁模式与当前的锁兼容， InnoDB 就将请求的锁授予该事务； 反之， 如果两者不兼容，该事务就要等待锁释放。）

## **InnoDB加锁方法：**

-   意向锁是 InnoDB 自动加的， 不需用户干预。
    
-   对于 UPDATE、 DELETE 和 INSERT 语句， InnoDB 会自动给涉及数据集加排他锁（X)；
    
-   对于普通 SELECT 语句，InnoDB 不会加任何锁； 事务可以通过以下语句显式给记录集加共享锁或排他锁：
    
-   共享锁（S）：SELECT * FROM table_name WHERE ... LOCK IN SHARE MODE。 其他 session 仍然可以查询记录，并也可以对该记录加 share mode 的共享锁。但是如果当前事务需要对该记录进行更新操作，则很有可能造成死锁。
    
-   排他锁（X)：SELECT * FROM table_name WHERE ... FOR UPDATE。其他 session 可以查询该记录，但是不能对该记录加共享锁或排他锁，而是等待获得锁
    
-   **隐式锁定：**
    

InnoDB在事务执行过程中，使用两阶段锁协议：

随时都可以执行锁定，InnoDB会根据隔离级别在需要的时候自动加锁；

锁只有在执行commit或者rollback的时候才会释放，并且所有的锁都是在**同一时刻**被释放。

-   **显式锁定 ：**
    

 select ... lock in share mode //共享锁   
 select ... for update //排他锁

**select for update：**

在执行这个 select 查询语句的时候，会将对应的索引访问条目进行上排他锁（X 锁），也就是说这个语句对应的锁就相当于update带来的效果。

select *** for update 的使用场景：为了让自己查到的数据确保是最新数据，并且查到后的数据只允许自己来修改的时候，需要用到 for update 子句。

**select lock in share mode ：**in share mode 子句的作用就是将查找到的数据加上一个 share 锁，这个就是表示其他的事务只能对这些数据进行简单的select 操作，并不能够进行 DML 操作。select *** lock in share mode 使用场景：为了确保自己查到的数据没有被其他的事务正在修改，也就是说确保查到的数据是最新的数据，并且不允许其他人来修改数据。但是自己不一定能够修改数据，因为有可能其他的事务也对这些数据 使用了 in share mode 的方式上了 S 锁。

**性能影响：** select for update 语句，相当于一个 update 语句。在业务繁忙的情况下，如果事务没有及时的commit或者rollback 可能会造成其他事务长时间的等待，从而影响数据库的并发使用效率。 select lock in share mode 语句是一个给查找的数据上一个共享锁（S 锁）的功能，它允许其他的事务也对该数据上S锁，但是不能够允许对该数据进行修改。如果不及时的commit 或者rollback 也可能会造成大量的事务等待。

**for update 和 lock in share mode 的区别：**

前一个上的是排他锁（X 锁），一旦一个事务获取了这个锁，其他的事务是没法在这些数据上执行 for update ；后一个是共享锁，多个事务可以同时的对相同数据执行 lock in share mode。

## **InnoDB 行锁实现方式：**

-   InnoDB 行锁是通过给索引上的索引项加锁来实现的，这一点 MySQL 与 Oracle 不同，后者是通过在数据块中对相应数据行加锁来实现的。InnoDB 这种行锁实现特点意味着：只有通过索引条件检索数据，InnoDB 才使用行级锁，否则，InnoDB 将使用表锁！
    
-   不论是使用主键索引、唯一索引或普通索引，InnoDB 都会使用行锁来对数据加锁。
    
-   只有执行计划真正使用了索引，才能使用行锁：即便在条件中使用了索引字段，但是否使用索引来检索数据是由 MySQL 通过判断不同执行计划的代价来决定的，如果 MySQL 认为全表扫描效率更高，比如对一些很小的表，它就不会使用索引，这种情况下 InnoDB 将使用表锁，而不是行锁。因此，在分析锁冲突时， 别忘了检查 SQL 的执行计划（可以通过 explain 检查 SQL 的执行计划），以确认是否真正使用了索引。（更多阅读：[MySQL索引总结](https://link.zhihu.com/?target=http%3A//mp.weixin.qq.com/s/h4B84UmzAUJ81iBY_FXNOg)）
    
-   由于 MySQL 的行锁是针对索引加的锁，不是针对记录加的锁，所以虽然多个session是访问不同行的记录， 但是如果是使用相同的索引键， 是会出现锁冲突的（后使用这些索引的session需要等待先使用索引的session释放锁后，才能获取锁）。 应用设计的时候要注意这一点。
    

## **InnoDB的间隙锁：**

当我们用范围条件而不是相等条件检索数据，并请求共享或排他锁时，InnoDB会给符合条件的已有数据记录的索引项加锁；对于键值在条件范围内但并不存在的记录，叫做“间隙（GAP)”，InnoDB也会对这个“间隙”加锁，这种锁机制就是所谓的间隙锁（Next-Key锁）。

很显然，在使用范围条件检索并锁定记录时，InnoDB这种加锁机制会阻塞符合条件范围内键值的并发插入，这往往会造成严重的锁等待。因此，在实际应用开发中，尤其是并发插入比较多的应用，我们要尽量优化业务逻辑，尽量使用相等条件来访问更新数据，避免使用范围条件。

**InnoDB使用间隙锁的目的：**

1.  防止幻读，以满足相关隔离级别的要求；
    
2.  满足恢复和复制的需要：
    

MySQL 通过 BINLOG 录入执行成功的 INSERT、UPDATE、DELETE 等更新数据的 SQL 语句，并由此实现 MySQL 数据库的恢复和主从复制。MySQL 的恢复机制（复制其实就是在 Slave Mysql 不断做基于 BINLOG 的恢复）有以下特点：

一是 MySQL 的恢复是 SQL 语句级的，也就是重新执行 BINLOG 中的 SQL 语句。

二是 MySQL 的 Binlog 是按照事务提交的先后顺序记录的， 恢复也是按这个顺序进行的。

由此可见，MySQL 的恢复机制要求：在一个事务未提交前，其他并发事务不能插入满足其锁定条件的任何记录，也就是不允许出现幻读。

## **InnoDB 在不同隔离级别下的一致性读及锁的差异：**

锁和多版本数据（MVCC）是 InnoDB 实现一致性读和 ISO/ANSI SQL92 隔离级别的手段。

因此，在不同的隔离级别下，InnoDB 处理 SQL 时采用的一致性读策略和需要的锁是不同的：

![](https://pic2.zhimg.com/v2-c83c6459f8dc93a5f157fe1e3080088d_b.jpg#id=zqVFz&originHeight=215&originWidth=597&originalType=binary&ratio=1&status=done&style=none)

![](https://pic1.zhimg.com/v2-568951f4cdfeb9416042627a7b94c4ac_b.jpg#id=H3DYc&originHeight=768&originWidth=594&originalType=binary&ratio=1&status=done&style=none)

对于许多 SQL，隔离级别越高，InnoDB 给记录集加的锁就越严格（尤其是使用范围条件的时候），产生锁冲突的可能性也就越高，从而对并发性事务处理性能的 影响也就越大。

因此， 我们在应用中， 应该尽量使用较低的隔离级别， 以减少锁争用的机率。实际上，通过优化事务逻辑，大部分应用使用 Read Commited 隔离级别就足够了。对于一些确实需要更高隔离级别的事务， 可以通过在程序中执行 SET SESSION TRANSACTION ISOLATION

LEVEL REPEATABLE READ 或 SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE 动态改变隔离级别的方式满足需求。

## **获取 InnoDB 行锁争用情况：**

可以通过检查 InnoDB_row_lock 状态变量来分析系统上的行锁的争夺情况：

 mysql> show status like 'innodb_row_lock%';   
 +-------------------------------+-------+   
 | Variable_name | Value |   
 +-------------------------------+-------+   
 | InnoDB_row_lock_current_waits | 0 |   
 | InnoDB_row_lock_time | 0 |   
 | InnoDB_row_lock_time_avg | 0 |   
 | InnoDB_row_lock_time_max | 0 |   
 | InnoDB_row_lock_waits | 0 |   
 +-------------------------------+-------+   
 5 rows in set (0.01 sec)

## **LOCK TABLES 和 UNLOCK TABLES**

Mysql也支持lock tables和unlock tables，这都是在服务器层（MySQL Server层）实现的，和存储引擎无关，它们有自己的用途，并不能替代事务处理。 （除了禁用了autocommint后可以使用，其他情况不建议使用）：

-   LOCK TABLES 可以锁定用于当前线程的表。如果表被其他线程锁定，则当前线程会等待，直到可以获取所有锁定为止。
    
-   UNLOCK TABLES 可以释放当前线程获得的任何锁定。当前线程执行另一个 LOCK TABLES 时， 或当与服务器的连接被关闭时，所有由当前线程锁定的表被隐含地解锁
    

## **LOCK TABLES语法：**

-   在用 LOCK TABLES 对 InnoDB 表加锁时要注意，要将 AUTOCOMMIT 设为 0，否则MySQL 不会给表加锁；
    
-   事务结束前，不要用 UNLOCK TABLES 释放表锁，因为 UNLOCK TABLES会隐含地提交事务；
    
-   COMMIT 或 ROLLBACK 并不能释放用 LOCK TABLES 加的表级锁，必须用UNLOCK TABLES 释放表锁。
    

正确的方式见如下语句： 例如，如果需要写表 t1 并从表 t 读，可以按如下做：

 SET AUTOCOMMIT=0;   
 LOCK TABLES t1 WRITE, t2 READ, ...;   
 [do something with tables t1 and t2 here];   
 COMMIT;   
 UNLOCK TABLES;

## **使用LOCK TABLES的场景：**

给表显示加表级锁（InnoDB表和MyISAM都可以），一般是为了在一定程度模拟事务操作，实现对某一时间点多个表的一致性读取。（与MyISAM默认的表锁行为类似）

在用 LOCK TABLES 给表显式加表锁时，必须同时取得所有涉及到表的锁，并且 MySQL 不支持锁升级。也就是说，在执行 LOCK TABLES 后，只能访问显式加锁的这些表，不能访问未加锁的表；同时，如果加的是读锁，那么只能执行查询操作，而不能执行更新操作。

其实，在MyISAM自动加锁（表锁）的情况下也大致如此，MyISAM 总是一次获得 SQL 语句所需要的全部锁，这也正是 MyISAM 表不会出现死锁（Deadlock Free）的原因。

例如，有一个订单表 orders，其中记录有各订单的总金额 total，同时还有一个 订单明细表 order_detail，其中记录有各订单每一产品的金额小计 subtotal，假设我们需要检 查这两个表的金额合计是否相符，可能就需要执行如下两条 SQL：

 Select sum(total) from orders;   
 Select sum(subtotal) from order_detail;

这时，如果不先给两个表加锁，就可能产生错误的结果，因为第一条语句执行过程中， order_detail 表可能已经发生了改变。因此，正确的方法应该是：

 Lock tables orders read local, order_detail read local;   
 Select sum(total) from orders;   
 Select sum(subtotal) from order_detail;   
 Unlock tables;

（在 LOCK TABLES 时加了“local”选项，其作用就是允许当你持有表的读锁时，其他用户可以在满足 MyISAM 表并发插入条件的情况下，在表尾并发插入记录（MyISAM 存储引擎支持“并发插入”））

## **死锁（Deadlock Free）**

-   **死锁产生：**
    
-   死锁是指两个或多个事务在同一资源上相互占用，并请求锁定对方占用的资源，从而导致恶性循环。
    
-   当事务试图以不同的顺序锁定资源时，就可能产生死锁。多个事务同时锁定同一个资源时也可能会产生死锁。
    
-   锁的行为和顺序和存储引擎相关。以同样的顺序执行语句，有些存储引擎会产生死锁有些不会——死锁有双重原因：真正的数据冲突；存储引擎的实现方式。
    
-   **检测死锁：**数据库系统实现了各种死锁检测和死锁超时的机制。InnoDB存储引擎能检测到死锁的循环依赖并立即返回一个错误。
    
-   **死锁恢复：**死锁发生以后，只有部分或完全回滚其中一个事务，才能打破死锁，InnoDB目前处理死锁的方法是，将持有最少行级排他锁的事务进行回滚。所以事务型应用程序在设计时必须考虑如何处理死锁，多数情况下只需要重新执行因死锁回滚的事务即可。
    
-   **外部锁的死锁检测：**发生死锁后，InnoDB 一般都能自动检测到，并使一个事务释放锁并回退，另一个事务获得锁，继续完成事务。但在涉及外部锁，或涉及表锁的情况下，InnoDB 并不能完全自动检测到死锁， 这需要通过设置锁等待超时参数 innodb_lock_wait_timeout 来解决
    
-   **死锁影响性能：**死锁会影响性能而不是会产生严重错误，因为InnoDB会自动检测死锁状况并回滚其中一个受影响的事务。在高并发系统上，当许多线程等待同一个锁时，死锁检测可能导致速度变慢。 有时当发生死锁时，禁用死锁检测（使用innodb_deadlock_detect配置选项）可能会更有效，这时可以依赖innodb_lock_wait_timeout设置进行事务回滚。
    

## **MyISAM避免死锁：**

-   在自动加锁的情况下，MyISAM 总是一次获得 SQL 语句所需要的全部锁，所以 MyISAM 表不会出现死锁。
    

## **InnoDB避免死锁：**

-   为了在单个InnoDB表上执行多个并发写入操作时避免死锁，可以在事务开始时通过为预期要修改的每个元祖（行）使用SELECT ... FOR UPDATE语句来获取必要的锁，即使这些行的更改语句是在之后才执行的。
    
-   在事务中，如果要更新记录，应该直接申请足够级别的锁，即排他锁，而不应先申请共享锁、更新时再申请排他锁，因为这时候当用户再申请排他锁时，其他事务可能又已经获得了相同记录的共享锁，从而造成锁冲突，甚至死锁
    
-   如果事务需要修改或锁定多个表，则应在每个事务中以相同的顺序使用加锁语句。 在应用中，如果不同的程序会并发存取多个表，应尽量约定以相同的顺序来访问表，这样可以大大降低产生死锁的机会
    
-   通过SELECT ... LOCK IN SHARE MODE获取行的读锁后，如果当前事务再需要对该记录进行更新操作，则很有可能造成死锁。
    
-   改变事务隔离级别
    

如果出现死锁，可以用 SHOW INNODB STATUS 命令来确定最后一个死锁产生的原因。返回结果中包括死锁相关事务的详细信息，如引发死锁的 SQL 语句，事务已经获得的锁，正在等待什么锁，以及被回滚的事务等。据此可以分析死锁产生的原因和改进措施。

## **一些优化锁性能的建议**

-   尽量使用较低的隔离级别；
    
-   精心设计索引， 并尽量使用索引访问数据， 使加锁更精确， 从而减少锁冲突的机会
    
-   选择合理的事务大小，小事务发生锁冲突的几率也更小
    
-   给记录集显示加锁时，最好一次性请求足够级别的锁。比如要修改数据的话，最好直接申请排他锁，而不是先申请共享锁，修改时再请求排他锁，这样容易产生死锁
    
-   不同的程序访问一组表时，应尽量约定以相同的顺序访问各表，对一个表而言，尽可能以固定的顺序存取表中的行。这样可以大大减少死锁的机会
    
-   尽量用相等条件访问数据，这样可以避免间隙锁对并发插入的影响
    
-   不要申请超过实际需要的锁级别
    
-   除非必须，查询时不要显示加锁。 MySQL的MVCC可以实现事务中的查询不用加锁，优化事务性能；MVCC只在COMMITTED READ（读提交）和REPEATABLE READ（可重复读）两种隔离级别下工作
    
-   对于一些特定的事务，可以使用表锁来提高处理速度或减少死锁的可能
    

## **乐观锁、悲观锁**

-   **乐观锁(Optimistic Lock)**：假设不会发生并发冲突，只在提交操作时检查是否违反数据完整性。 乐观锁不能解决脏读的问题。
    

乐观锁, 顾名思义，就是很乐观，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用版本号等机制。乐观锁适用于多读的应用类型，这样可以提高吞吐量，像数据库如果提供类似于write_condition机制的其实都是提供的乐观锁。

-   **悲观锁(Pessimistic Lock)**：假定会发生并发冲突，屏蔽一切可能违反数据完整性的操作。
    

悲观锁，顾名思义，就是很悲观，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会block直到它拿到锁。传统的关系型数据库里边就用到了很多这种锁机制，比如行锁，表锁等，读锁，写锁等，都是在做操作之前先上锁。

 参考：  
 《高性能MySQL》  
 《深入浅出MySQL》  
 http://www.cnblogs.com/liushuiwuqing/p/3966898.html   
 https://dev.mysql.com/doc/refman/5.7/en/internal-locking.html   
 http://www.cnblogs.com/0201zcr/p/4782283.html

只有通过索引进行检索的时候才会使用行级锁，如果不是通过索引进行检索就会升级成表锁。 行锁是为了最大并发化所提供的一种锁，封锁某一行数据。我知道的 mysql 行锁有三种，就间隙锁使用场景，我分成了唯一索引和非唯一索引两种情况。记住所有的for update都是当前读并且加上行锁，跟快照读不一样， （1）按对数据操作： 读锁（共享锁）：多个读操作可以同时进行，互不干扰 写锁（互斥锁）：如果当前写操作没有完毕，则无法进行其他读操作和写操作。 （2）按粒度分：表锁和行锁 表锁： 偏小 myisam 存储引擎，开销小，无死锁，容易发生锁冲突，并发度低。 lock table 表名字 1 read(write)，表名字 2 read(write)，其它 行锁 偏向 innodb,开销大，支持事务 总的来说，Innodb 共有其中类型的锁

## 1：共享/排它锁（Shared and Exclusive Locks）

## 2：意向锁（Intention Locks）

InnoDB 为了支持多粒度锁机制(multiple granularity locking)，即允许行级锁与表级锁共存，而引入了意向锁(intention locks)。意向锁是指，未来的某个时刻，事务可能要加共享/排它锁了，先提前声明一个意向。

1. 意向锁是一个表级别的锁(table-level locking)；
2. 意向锁又分为：
   - 意向共享锁(intention shared lock, IS)，它预示着，事务有意向对表中的某些行加共享 S 锁；
   - 意向排它锁(intention exclusive lock, IX)，它预示着，事务有意向对表中的某些行加排它 X 锁；

加锁的语法为：

```
select ... lock in share mode;　　要设置IS锁；
select ... for update;　　　　　　 要设置IX锁；
```

事务要获得某些行的 S/X 锁，必须先获得表对应的 IS/IX 锁，意向锁仅仅表明意向，意向锁之间相互兼容，兼容互斥表如下：

|     | IS    | IX    |
| --- | ----- | ----- |
| IS  | 兼 容 | 兼 容 |
| IX  | 兼 容 | 兼 容 |

虽然意向锁之间互相兼容，但是它与共享锁/排它锁互斥，其兼容互斥表如下:

| S   | X     |       |
| --- | ----- | ----- |
| IS  | 兼 容 | 互 斥 |
| IX  | 互 斥 | 互 斥 |

## 记录锁（Record Locks）

记录锁，它封锁索引记录

## 间隙锁（Gap Locks）

间隙锁，它封锁索引记录中的间隔，或者第一条索引记录之前的范围，又或者最后一条索引记录之后的范围。

间隙锁一般都是针对非唯一索引而言的，它会对相邻的区间进行封锁，被锁上的区间内的值是无法再被使用的。当那个条件不存在的时候会找表中存在的相邻数据，然后再进行加锁。

当主键做为条件的时候，不存在间隙锁，除非手动指定范围。

间隙锁：是 Innodb 在可重复读提交下为了解决幻读问题时引入的锁机制，幻读是因为新增或则更新操作，这时如果进行范围查询的时候（加锁查询）会出现不一致的问题。

加锁特性：

1.加锁的基本单位是（next-key lock）,他是前开后闭原则

2.插叙过程中访问的对象会增加锁

3.索引上的等值查询--给唯一索引加锁的时候，next-key lock 升级为行锁

4.索引上的等值查询--部分命中或者全不命中，next-key lock 退化为间隙锁

5.唯一索引上的范围查询会访问到不满足条件的第一个值为止

间隙锁死锁问题：

不同于写锁相互之间是互斥的原则，间隙锁之间不是互斥的，如果一个事务 A 获取到了（5,10]之间的间隙锁，另一个事务 B 也可以获取到（5,10]之间的间隙锁。这时就可能会发生死锁问题，

![image-20210309101841660](../../../4三千道藏/media/image-20210309101841660.png)

## 临键锁（Next-key Locks）

临键锁，是记录锁与间隙锁的组合，它的封锁范围，既包含索引记录，又包含索引区间。

默认情况下，innodb 使用 next-key locks 来锁定记录。但当查询的索引含有唯一属性的时候，Next-Key Lock 会进行优化，将其降级为 Record Lock，即仅锁住索引本身，不是范围。

但是 id 降级为普通索引(key)，也就是说即使这里声明了要加锁(for update)，而且命中的是索引，但是因为索引在这里没有 UK 约束，所以 innodb 会使用 next-key locks，数据库隔离级别 RR：

```
事务A执行如下语句，未提交：
select * from lock_example where id = 20 for update;

事务B开始，执行如下语句，会阻塞：
insert into lock_example values('zhang',15);
```

如上的例子，事务 A 执行查询语句之后，默认给 id=20 这条记录加上了 next-key lock，所以事务 B 插入 10(包括)到 30(不包括)之间的记录都会阻塞。临键锁的主要目的，也是为了避免幻读(Phantom Read)。如果把事务的隔离级别**降级为 RC，临键锁则也会失效**。

## 插入意向锁（Insert Intention Locks）

对已有数据行的修改与删除，必须加强互斥锁(X 锁)，那么对于数据的插入，是否还需要加这么强的锁，来实施互斥呢？插入意向锁，孕育而生。

插入意向锁，是间隙锁(Gap Locks)的一种（所以，也是实施在索引上的），它是专门针对 insert 操作的。多个事务，在同一个索引，同一个范围区间插入记录时，如果插入的位置不冲突，不会阻塞彼此。

事务 A 先执行，在 10 与 20 两条记录中插入了一行，还未提交：

```
insert into t values(11, xxx);
```

事务 B 后执行，也在 10 与 20 两条记录中插入了一行：

```
insert into t values(12, ooo);
```

因为是插入操作，虽然是插入同一个区间，但是插入的记录并不冲突，所以使用的是插入意向锁，此处 A 事务并不会阻塞 B 事务。

- 自增锁（Auto-inc Locks）

自增锁是一种特殊的表级别锁（table-level lock），专门针对事务插入 AUTO_INCREMENT 类型的列。最简单的情况，如果一个事务正在往表中插入记录，所有其他事务的插入必须等待，以便第一个事务插入的行，是连续的主键值。

比如：

事务 A 先执行，还未提交： insert into t(name) values(xxx);

事务 B 后执行： insert into t(name) values(ooo);

此时事务 B 插入操作会阻塞，直到事务 A 提交。

总结：

**1. 按锁的互斥程度来划分，可以分为共享、排他锁；**

- 共享锁(S 锁、IS 锁)，可以提高读读并发；

- 为了保证数据强一致，InnoDB 使用强互斥锁(X 锁、IX 锁)，保证同一行记录修改与删除的串行性；

**2. 按锁的粒度来划分，可以分为：**

- 表锁：意向锁(IS 锁、IX 锁)、自增锁；

- 行锁：记录锁、间隙锁、临键锁、插入意向锁；

其中

1. InnoDB 的细粒度锁(即行锁)，是实现在索引记录上的(我的理解是如果未命中索引则会失效)；
2. 记录锁锁定索引记录；间隙锁锁定间隔，防止间隔中被其他事务插入；临键锁锁定索引记录+间隔，防止幻读；
3. InnoDB 使用插入意向锁，可以提高插入并发；
4. 间隙锁(gap lock)与临键锁(next-key lock)**只在 RR 以上的级别生效，RC 下会失效**；

4：间隙锁：

当我们用范围条件而不是相等条件检索数据，并请求共享或排他锁时，InnoDB 会给符合条件的已有数据记录的索引项加锁；对于键值在条件范围内但并不存在的记录，叫做“间隙（GAP)”，
InnoDB 也会对这个“间隙”加锁，这种锁机制就是所谓的间隙锁（GAP Lock）。

因为 Query 执行过程中通过过范围查找的话，他会锁定整个范围内所有的索引键值，即使这个键值并不存在。
间隙锁有一个比较致命的弱点，就是当锁定一个范围键值之后，即使某些不存在的键值也会被无辜的锁定，而造成在锁定的时候无法插入锁定键值范围内的任何数据。在某些场景下这可能会对性能造成很大的危害

```sql
--查看哪些表加了锁
show open tables;--1代表被加了锁
--分析表锁定的严重程度
show status like 'table%'
参数：Table_locks_immediate:即可能获取到的锁数
参数：Table_waited:需要等待的表锁数，该值越大锁竞争越大
```

## mysql 是如何实现悲观锁与乐观锁的？

一锁二查三更新”即指的是使用悲观锁。通常来讲在数据库上的悲观锁需要数据库本身提供支持，即通过常用的 select … for update 操作来实现悲观锁。

当数据库执行 select for update 时会获取被 select 中的数据行的行锁，因此其他并发执行的 select for update 如果试图选中同一行则会发生排斥（需要等待行锁被释放），因此达到锁的效果。select for update 获取的行锁会在当前事务结束时自动释放，因此必须在事务中使用。

**mysql 还有个问题是 select... for update 语句执行中，如果数据表没有添加索引或主键，所有扫描过的行都会被锁上，这一点很容易造成问题。因此如果在 mysql 中用悲观锁务必要确定走了索引，而不是全表扫描。**

**要使用悲观锁，我们必须关闭 mysql 数据库的自动提交属性，因为 MySQL 默认使用 autocommit 模式，也就是说，当你执行一个更新操作后，MySQL 会立刻将结果进行提交。**

乐观锁的三种实现方式：

1：使用数据版本（Version）记录机制实现，这是乐观锁最常用的一种实现方式。何谓数据版本？即为数据增加一个版本标识，一般是通过为数据库表增加一个数字类型的 “version” 字段来实现。当读取数据时，将 version 字段的值一同读出，数据每更新一次，对此 version 值加一。当我们提交更新的时候，判断数据库表对应记录的当前版本信息与第一次取出来的 version 值进行比对，如果数据库表当前版本号与第一次取出来的 version 值相等，则予以更新，否则认为是过期数据，

2：使用时间戳（timestamp）, 和上面的 version 类似，也是在更新提交的时候检查当前数据库中数据的时间戳和自己更新前取到的时间戳进行对比，如果一致则 OK，否则就是版本冲突。

|               | **悲观锁**                                             | **乐观锁**                               |
| ------------- | ------------------------------------------------------ | ---------------------------------------- |
| **概念**      | **查询时直接锁住记录使得其它事务不能查询，更不能更新** | **提交更新时检查版本或者时间戳是否符合** |
| **语法**      | **select ... for update**                              | **使用 version 或者 timestamp 进行比较** |
| **实现者**    | **数据库本身**                                         | **开发者**                               |
| **适用场景**  | **并发量大**                                           | **并发量小**                             |
| **类比 Java** | **Synchronized 关键字**                                | **CAS 算法**                             |

实这种版本号的方法并不是适用于所有的乐观锁场景。举个例子，当电商抢购活动时，大量并发进入，如果仅仅使用版本号或者时间戳，就会出现大量的用户查询出库存存在，但是却在扣减库存时失败了，而这个时候库存是确实存在的。想象一下，版本号每次只会有一个用户扣减成功，不可避免的人为造成失败。这种时候就需要我们的第二种场景的乐观锁方法。

```sql
UPDATE t_goods
SET num = num - #{buyNum}
WHERE
    id = #{id}
AND num - #{buyNum} >= 0
AND STATUS = 1
```

说明：num-#{buyNum}>=0 ，这个情景适合不用版本号，只更新是做数据安全校验，适合库存模型，扣份额和回滚份额，性能更高。这种模式也是目前我用来锁产品库存的方法，十分方便实用。

**更新操作，最好用主键或者唯一索引来更新,这样是行锁，否则更新时会锁表**

## 死锁问题

在可重复读级别下，因为加锁导致两个事务出现死锁。

排查：

```sql
-- Oracle
--查看死锁用户，状态，机器，程序
select username,lockwait,status,machine,program from v$session where sid in (select session_id from v$locked_object)
-- 查看被死锁的语句
select sql_text from v$sql where hash_value in (select sql_hash_value from v$session where sid in (select session_id from v$locked_object))
---mysql
1：查看当前事务
select * from information_schema.innodb_trx;
2:查看当前锁定的事务
select * from information_schema.innodb_lock;
3:查看当前等锁的事务
select * from information_schema.innofb_lock_waits;
```

解决方案：

1：已经出现，查找，杀掉

```sql
---Oracle
--查找死锁进程
select s.username,I.object_id,I.session_id,s.serial#,I.oracle_username,I.os_user_name,I.process from v$locked_object I,v$session s where I.session_id = s.sid;
--kill 掉这个死锁的进程
alter system kill session 'sid,serial#';(其中sid = I.session_id)
```

1：数据库级别设置超时时间

```properties
[mysqld]
log-error =/var/log/mysqld3306.log
innodb_lock_wait_timeout=60     #锁请求超时时间(秒)
innodb_rollback_on_timeout = 1  #事务中某个语句锁请求超时将回滚整个事务
innodb_print_all_deadlocks = 1  #死锁都保存到错误日志
```

死锁的可能情况：

1：程序问题

用户X访问表a锁住然后又申请访问B，用户Y访问B并锁住申请访问a。

解决：调整逻辑，仔细分析程序逻辑，对于数据的多表操作，尽量按照相同的顺序进行处理。

2：锁升级

用户A查询一条纪录，然后修改该条纪录；这时用户B修改该条纪录，这时用户A的事务里锁的性质由查询的共享锁企图上升到独占锁，而用户B里的独占锁由于A 有共享锁存在所以必须等A释放掉共享锁，而A由于B的独占锁而无法上升的独占锁也就不可能释放共享锁，于是出现了死锁。——真的会出现吗，独占和共享可以同时存在？

解决：

3：全表扫描

如果在事务中执行了一条不满足条件的update语句，则执行全表扫描，把行级锁上升为表级锁，多个这样的事务执行后，就很容易产生死锁和阻塞。

解决：

SQL语句不要使用太复杂的关联多表查询；explain对于有全表扫描的SQL语句建立索引；

# 19：服务器级常用 sql 语句

```sql
--查看表空间
select concat(round(sum(index_length)/(1024*1024),2),'MB') AS 'MB' ,'Index Data Size' as TABLESPACE from information_schema.TABLE where table_schema='alp'

select
	a.tablespace_name "表空间名"，
	total "表空间大小",
	free "表空间剩余大小",
	(total - free) "表空间使用大小",
	total/(1024*1024*1024) "表空间大小(G)",
	free/(1024*1024*1024) "表空间剩余大小(G)",
	(total - free)/(1024*1024*1024) "表空间使用大小(G)",
	round((total - free)/total,4) * 100 "使用率%",
	from (select tablespace_name,sum(bytes) free
         from dba_free_space
         group by tablespace_name) a,
         (select tablespace_name,sum(bytes) total
         from dba_data_files
          group by tablespace_name) b
```

## 19、数据库设计的三范式

### 19.1、第一范式

数据库表中不能出现重复记录，每个字段是原子性的不能再分

不符合第一范式的示例

| 学生编号 | 学生姓名 | 联系方式                   |
| -------- | -------- | -------------------------- |
| 1001     | 张三     | zs\@gmail.com,1359999999   |
| 1002     | 李四     | <ls@gmail.com>,13699999999 |
| 1001     | 王五     | ww\@163.net,13488888888    |

存在问题：

- 最后一条记录和第一条重复（不唯一，没有主键）

  - 联系方式字段可以再分，不是原子性的

| 学生编号(pk) | 学生姓名 | email          | 联系电话    |
| ------------ | -------- | -------------- | ----------- |
| 1001         | 张三     | zs\@gmail.com  | 1359999999  |
| 1002         | 李四     | <ls@gmail.com> | 13699999999 |
| 1003         | 王五     | <ww@163.net>   | 13488888888 |

关于第一范式，每一行必须唯一，也就是每个表必须有主键，这是我们数据库设计的最基本要求，主要通常采用数值型或定长字符串表示，关于列不可再分，应该根据具体的情况来决定。如联系方式，为了开发上的便利行可能就采用一个字段了。

### 19.2、第二范式

第二范式是建立在第一范式基础上的，另外要求所有非主键字段完全依赖主键，不能产生部分依赖

示例：

| 学生编号 | 学生姓名 | 教师编号 | 教师姓名 |
| -------- | -------- | -------- | -------- |
| 1001     | 张三     | 001      | 王老师   |
| 1002     | 李四     | 002      | 赵老师   |
| 1003     | 王五     | 001      | 王老师   |
| 1001     | 张三     | 002      | 赵老师   |

确定主键：

| 学生编号(PK) | 教师编号(PK) | 学生姓名 | 教师姓名 |
| ------------ | ------------ | -------- | -------- |
| 1001         | 001          | 张三     | 王老师   |
| 1002         | 002          | 李四     | 赵老师   |
| 1003         | 001          | 王五     | 王老师   |
| 1001         | 002          | 张三     | 赵老师   |

以上虽然确定了主键，但此表会出现大量的冗余，主要涉及到的冗余字段为“学生姓名”和“教师姓名”，出现冗余的原因在于，学生姓名部分依赖了主键的一个字段学生编号，而没有依赖教师编号，而教师姓名部门依赖了主键的一个字段教师编号，这就是第二范式部分依赖。

解决方案如下：

学生信息表

| 学生编号（PK） | 学生姓名 |
| -------------- | -------- |
| 1001           | 张三     |
| 1002           | 李四     |
| 1003           | 王五     |

教师信息表

| 教师编号（PK） | 教师姓名 |
| -------------- | -------- |
| 001            | 王老师   |
| 002            | 赵老师   |

教师和学生的关系表

| 学生编号(PK) fk 学生表的学生编号 | 教师编号(PK) fk 教师表的教师编号 |
| -------------------------------- | -------------------------------- |
| 1001                             | 001                              |
| 1002                             | 002                              |
| 1003                             | 001                              |
| 1001                             | 002                              |

如果一个表是单一主键，那么它就复合第二范式，部分依赖和主键有关系

**以上是一种典型的“多对多”的设计**

### 19.3、第三范式

建立在第二范式基础上的，非主键字段不能传递依赖于主键字段。（**不要产生传递依赖**）

| 学生编号（PK） | 学生姓名 | 班级编号 | 班级名称 |
| -------------- | -------- | -------- | -------- |
| 1001           | 张三     | 01       | 一年一班 |
| 1002           | 李四     | 02       | 一年二班 |
| 1003           | 王五     | 03       | 一年三班 |
| 1004           | 六       | 03       | 一年三班 |

从上表可以看出，班级名称字段存在冗余，因为班级名称字段没有直接依赖于主键，班级名称字段依赖于班级编号，班级编号依赖于学生编号，那么这就是传递依赖，解决的办法是将冗余字段单独拿出来建立表，如：

学生信息表

| 学生编号（PK） | 学生姓名 | 班级编号（FK） |
| -------------- | -------- | -------------- |
| 1001           | 张三     | 01             |
| 1002           | 李四     | 02             |
| 1003           | 王五     | 03             |
| 1004           | 六       | 03             |

班级信息表

| 班级编号（PK） | 班级名称 |
| -------------- | -------- |
| 01             | 一年一班 |
| 02             | 一年二班 |
| 03             | 一年三班 |

**以上设计是一种典型的一对多的设计，一存储在一张表中，多存储在一张表中，在多的那张表中添加外键指向一的一方的主键**

### 19.4、三范式总结

第一范式：有主键，具有原子性，字段不可分割

第二范式：完全依赖，没有部分依赖

第三范式：没有传递依赖

数据库设计尽量遵循三范式，但是还是根据实际情况进行取舍，有时可能会拿冗余换速度，最终用目的要满足客户需求。

**一对一设计，有两种设计方案：**

**第一种设计方案：主键共享**

**第二种设计方案：外键唯一**

# 22：MySQL 配置参数

**基本配置：**

**datadir**：指定 mysql 的数据目录位置，用于存放 mysql 数据库文件、日志文件等。

配置示例：datadir=D:/wamp/mysqldata/Data

**default-character-set**：mysql 服务器默认字符集设置。

配置示例：default-character-set=utf8

**skip-grant-tables**：当忘记 mysql 用户密码的时候，可以在 mysql 配置文件中配置该参数，跳过权限表验证，不需要密码即可登录 mysql。

**日志相关：**

**log-error**：指定错误日志文件名称，用于记录当 mysqld 启动和停止时，以及服务器在运行过程中发生任何严重错误时的相关信息。

配置示例：log-error="WJT-PC.err"（默认在 mysql 数据目录下）

**log-bin**：指定二进制日志文件名称，用于记录对数据造成更改的所有查询语句。

配置示例：log-bin="WJT-PC-bin.log"（默认在 mysql 数据目录下）

**binlog-do-db**：指定将更新记录到二进制日志的数据库，其他所有没有显式指定的数据库更新将被忽略，不记录在日志中。

配置示例：binlog-do-db=db_name

**binlog-ignore-db**：指定不将更新记录到二进制日志的数据库，其他没有显式忽略的数据库都将进行记录。

配置示例：binlog-ignore-db=db_name 如果想记录或忽略多个数据库，可以对上面两个选项分别使用多次。

**sync-binlog**：指定多少次写日志后同步磁盘。

配置示例：sync-binlog=N

**general-log**：是否开启查询日志记录。

配置示例：general-log=1

**general_log_file**：指定查询日志文件名，用于记录所有的查询语句。

配置示例：general_log_file="WJT-PC.log"（默认在 mysql 数据目录下）

**slow-query-log**：是否开启慢查询日志记录。

配置示例：slow-query-log=1

**slow_query_log_file**：指定慢查询日志文件名称，用于记录消耗时间较长的查询语句。

配置示例：slow_query_log_file="WJT-PC-slow.log"（默认在 mysql 数据目录下）

**long_query_time**：设置慢查询的时间，超过这个时间的查询语句才记录日志。

配置示例：long_query_time=10（单位：秒）

**log-slow-admin-statements**：是否将慢管理语句（例如 OPTIMIZE TABLE、ANALYZE TABLE 和 ALTER TABLE）写入慢查询日志。

**存储引擎相关：**

**default-table-type**：设置 mysql 的默认存储引擎。

**innodb_data_home_dir**：InnoDB 引擎的共享表空间数据文件根目录。若没有设置，则使用 mysql 的 datadir 目录作为缺省目录。

**innodb_data_file_path**：单独指定共享表空间数据文件的路径与大小。数据文件的完整路径由 innodb_data_home_dir 与这里配置的值组合起来，文件大小以 MB 单位指定。

配置示例：innodb_data_home_dir=innodb_data_file_path=ibdata1:12M;/data/mysql/mysql3306/data1/ibdata2:12M:autoextend

如果想为 innodb 表空间指定不同目录下的文件，必须指定 innodb_data_home_dir =。这个例子中会在 datadir 下建立 ibdata1，在/data/MySQL/mysql3306/data1/目录下创建 ibdata2。

**innodb_file_per_table**：是否开启独立表空间，若开启，InnoDB 将使用独立的.idb 文件创建新表而不是在共享表空间中创建。

配置示例：innodb_file_per_table=1

**innodb_autoinc_lock_mode**：配置在向有着 auto_increment 列的表插入数据时，相关锁的行为。该参数有 3 个取值：

0：tradition 传统，所有的 insert 语 句开始的时候得到一个表级的 auto_inc 锁，在语句结束的时候才能释放 这个锁，影响了并发的插入。

1：consecutive 连续，mysql 可以一次生成 几个连续的 auto_inc 的值，auto_inc 不需要一直保持到语句结束，只要 语句得到了相应的值后就可以提前释放锁（这也是 mysql 的默认模式）。

2：interleaved 交错，这个模式下已经没有了 auto_inc 锁，所以性能是最好的，但是对于同一个语句来说它得到的 auto_inc 的值可能不是连续的。

配置示例：innodb_autoinc_lock_mode=1

**low_priority_updates**：在 myisam 引擎锁使用中，默认情况下写请求优先于读请求，可以通过将该参数设置为 1 来使 myisam 引擎给予读请求优先权限， 所有的 insert、update、delete 和 lock table write 语句将等待直到受影响的表没有挂起的 select 或 lock table read。

配置示例：low_priority_updates=0（默认配置）

**max_write_lock_count**：当一个 myisam 表的写锁定达到这个值后，mysql 就暂时 将写请求优先级降低，给部分读请求获得锁的机会。

**innodb_lock_wait_timeout**：InnoDB 锁等待超时参数，若事务在该时间内没有获 得需要的锁，则发生回滚。

配置示例：innodb_lock_wait_timeout=50（默认 50 秒）

**max_heap_table_size**：设置 memory 表的最大空间大小，该变量可以用来计算 memory 表的 max_rows 值。在已有 memory 表上设置该参数是没有效果 的，除非重建表。

**查询相关：**

**max_sort_length**：配置对 blob 或 text 类型的列进行排序时使用的字节数（只对配置的前 max_sort_length 个字节进行排序，其他的被忽略）

**max_length_for_sort**：mysql 有两种排序算法，两次传输排序和单次传输排序。当查询需要所有列的总长度不超过 max_length_for_sort 时，mysql 使用 单次传输排序，否则使用两次传输排序。

**optimizer_search_depth**：在关联查询中，当需要关联的表数量超过 optimizer_search_depth 的时候，优化器会使用“贪婪”搜索的方式查找“最优”的关联顺序。

## 21：问题

### 1：修改 mysql 的 root 密码

方法 1： 用 SET PASSWORD 命令

首先登录 MySQL。

格式：mysql\> set password for 用户名\@localhost = password('新密码');

例子：mysql\> set password for root\@localhost = password('123');

方法 2：用 mysqladmin

格式：mysqladmin -u 用户名 -p 旧密码 password 新密码

例子：mysqladmin -uroot -p123456 password 123

方法 3：用 UPDATE 直接编辑 user 表

首先登录 MySQL。

mysql\> use mysql;

mysql\> update user set password=password('123') where user='root' and
host='localhost';

mysql\> flush privileges;

方法 4：在忘记 root 密码的时候，可以这样

以 windows 为例：

1. 关闭正在运行的 MySQL 服务。
2. 打开 DOS 窗口，转到 mysql\\bin 目录。
3. 输入 mysqld --skip-grant-tables 回车。--skip-grant-tables
   的意思是启动 MySQL 服务的时候跳过权限表认证。
4. 再开一个 DOS 窗口（因为刚才那个 DOS 窗口已经不能动了），转到 mysql\\bin 目录。
5. 输入 mysql 回车，如果成功，将出现 MySQL 提示符 \>。
6. 连接权限数据库： use mysql; 。
7. 改密码：update user set password=password("123") where
   user="root";（别忘了最后加分号） 。
8. 刷新权限（必须步骤）：flush privileges; 。
9. 退出 quit。
10. 注销系统，再进入，使用用户名 root 和刚才设置的新密码 123 登录

### 2：Mysql 占用 CPU100%，如何处理？

mysql CPU 使用已达到接近 400%（因为是四核，所以会有超过 100%的情况）

在服务器上执行 mysql -u root -p 之后，输入 show full processlist; 可以看到正在执行的语句。

但是从数据库设计方面来说，该做的索引都已经做了，SQL 语句似乎没有优化的空间。

直接执行此条 SQL，发现速度很慢，需要 1-6 秒的时间（跟 mysql 正在并发执行的查询有关，如果没有并发的，需要 1 秒多）。如果把排序依据改为一个，则查询时间可以缩短至 0.01 秒（most_top）或者 0.001 秒（posttime）。

优化：

首先是缩减查询范围

### 怎么防止 sql 注入？

sql 注入：某些 sql 语句的参数没有进行合理校检，参数中可能有危害数据库的一些语句，导致语句出错。

使用预编译语句的支持

一条语句可能会反复执行，或许每次执行只有个别语句不同。

使用占位符替代，一次编译，多次运行。

mysql 使用 PrepareStatement

# 第十二章：MySQL 集群

## 主从复制

主从复制原理：

主库开启 binlog 日志，主库会生成一个 log dump 线程，用来给从库 i/o 线程传 binlog。

从库生成两个线程，一个 I/O 线程，一个 SQL 线程；i/o 线程去请求主库 的 binlog，并将得到的 binlog 日志写到 relay log（中继日志） 文件中；SQL 线程，会读取 relay log 文件中的日志，并解析成具体操作，来实现主从的操作一致，而最终数据一致；

## 读写分离

读写分离，基本的原理是让主数据库处理事务性增、改、删操作（INSERT、UPDATE、DELETE），而从数据库处理 SELECT 查询操作。数据库复制被用来把事务性操作导致的变更同步到集群中的从数据库。就搞一个主库，挂多个从库，然后我们就单单只是写主库，然后主库会自动把数据给同步到从库上去。一般情况下，主库可以挂 4-5 个从库

mysql 支持复制的类型：

1） 基于语句的复制。在服务器上执行 sql 语句，在从服务器上执行同样的语句，mysql 默认采用基于语句的复制，执行效率高。

2） 基于行的复制。把改变的内容复制过去，而不是把命令在从服务器上执行一遍。

3） 混合类型的复制。默认采用基于语句的复制，一旦发现基于语句无法精确复制时，就会采用基于行的复制。

复制的工作过程：

同上

根据主从复制的原理可知：

从库同步主库数据的过程是串行化的，也就是说主库上并行的操作，在从库上会串行执行。所以这就是一个非常重要的点了，由于从库从主库拷贝日志以及串行执行 SQL 的特点，在高并发场景下，从库的数据一定会比主库慢一些，是有延时的。所以经常出现，刚写入主库的数据可能是读不到的，要过几十毫秒，甚至几百毫秒才能读取到。

还有一个问题：如果主库宕机了，恰好数据还没同步到从库，这些数据可能就丢失了。

mysql 实际上在这一块有两个机制，一个是半同步复制，用来解决主库数据丢失问题；一个是并行复制，用来解决主从同步延时问题。

### 半同步复制

这个所谓半同步复制，semi-sync 复制，指的就是主库写入 binlog 日志之后，就会将强制此时立即将数据同步到从库，从库将日志写入自己本地的 relay log 之后，接着会返回一个 ack 给主库，主库接收到至少一个从库的 ack 之后才会认为写操作完成了。

### 并行复制

所谓并行复制，指的是从库开启多个线程，并行读取 relay log 中不同库的日志，然后并行重放不同库的日志，这是库级别的并行。

### 主从同步时延问题

所以实际上你要考虑好应该在什么场景下来用这个 mysql 主从同步，建议是一般在读远远多于写，而且读的时候一般对数据时效性要求没那么高的时候，用 mysql 主从同步

解决方案：

1：分库，分散压力，将一个主库拆分为 4 个主库，每个主库的写并发就 500/s，此时主从延迟可以忽略不计

2：在业务层和数据库之间使用 Redis 或 memcache，降低 mysql 读压力。

3：不同业务的数据库物理上放到不同的机器上。

4：打开 mysql 支持的并行复制，多个库并行复制，如果说某个库的写入并发就是特别高，单库写并发达到了 2000/s，并行复制还是没意义。28 法则，很多时候比如说，就是少数的几个订单表，写入了 2000/s，其他几十个表 10/s。但是问题是那是库级别的并行，所以有时候作用不是很大

5：重写代码，写代码的同学，要慎重，当时我们其实短期是让那个同学重写了一下代码，插入数据之后，直接就更新，不要查询

6：如果确实是存在必须先插入，立马要求就查询到，然后立马就要反过来执行一些操作，对这个查询设置直连主库。不推荐这种方法，你这么搞导致读写分离的意义就丧失了，采用强制读主库的方式，这样就可以保证你肯定的可以读到数据了吧。其实用一些数据库中间件是没问题的。

### 实现读写分离

一：基于程序代码实现：

在代码中根据 select 、insert 进行路由分类，这类方法也是目前生产环境下应用最广泛的。优点是性能较好，因为程序在代码中实现，不需要增加额外的硬件开支，缺点是需要开发人员来实现，运维人员无从下手。

二：代理中间件