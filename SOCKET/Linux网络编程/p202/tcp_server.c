/*
 * =====================================================================================
 *
 *       Filename:  tcp_server.c
 *
 *    Description:  服务器网络程序
 *
 *        Version:  1.0
 *        Created:  11/20/2011 03:10:44 PM
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
#define BACKLOG 2
#define PORT 8888
int main(int argc,char *argv[])
{
  int ss,sc;
  struct sockaddr_in server_addr;
  struct sockaddr_in client_addr;
  int err;
  pid_t pid;
  ss = socket(AF_INET,SOCK_STREAM,0);
  if(ss<0){
    printf("socket error\n");
    return -1;
  }
  bzero(&server_addr,sizeof(server_addr));
  server_addr.sin_family=AF_INET;
  server_addr.sin_addr.s_addr=htonl(INADDR_ANY);
  server_addr.sin_port=htons(PORT);

  err = bind(ss,(struct sockaddr*)&server_addr,sizeof(server_addr));
  if(err<0){
    printf("bindd error\n");
    return -1;
  }

  err = listen(ss,BACKLOG);
  if(err < 0){
    printf("listen error\n");
    return -1;
  }

  for(;;){
    int addrlen = sizeof(struct sockaddr);

    sc = accept(ss,(struct sockaddr*)&client_addr,&addrlen);
    if(sc < 0){
      continue;
    }
    pid = fork();
    if(pid == 0)
    {
      close(ss);
      process_conn_server(sc);
    }else{
      close(sc);
    }
  }
}

//void process_conn_server(int s)
//{
//  ssize_t size = 0;
//  char buffer[1024];
//
//  for(;;)
//  {
//    size = read(s,buffer,1024);
//
//    if(size == 0)
//    {
//      return;
//    }
//
//    sprintf(buffer,"%d bytes altogether\n",size);
//    write(s,buffer,strlen(buffer)+1);
//  }
//}
