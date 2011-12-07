/*
 * =====================================================================================
 *
 *       Filename:  tcp_proccess.c
 *
 *    Description:  服务端和客户端字符串处理
 *
 *        Version:  1.0
 *        Created:  11/20/2011 03:49:12 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Qingping Hou (houqp), dave2008713@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<sys/types.h>
#include<sys/socket.h>
#include<unistd.h>
#include<linux/in.h>
void process_conn_client(int s)
{
  size_t size = 0;
  char buffer[1024];

  for(;;)
  {
    size = read(0,buffer,1024);
    if(size > 0)
    {
      write(s,buffer,size);
      size = read(s,buffer,1024);
      write(2,buffer,size);
    }
  }
}

void process_conn_server(int s)
{
  ssize_t size = 0;
  char buffer[1024];

  for(;;)
  {
    size = read(s,buffer,1024);

    if(size == 0)
    {
      return;
    }

    sprintf(buffer,"%d bytes altogether\n",size);
    write(s,buffer,strlen(buffer)+1);
  }
}
