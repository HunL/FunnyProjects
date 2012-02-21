/*
 * =====================================================================================
 *
 *       Filename:  client.c
 *
 *    Description:  传送文件的客户端程序
 *
 *        Version:  1.0
 *        Created:  12/02/2011 10:43:49 PM
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
#include<string.h>//for bzero
#include<errno.h>//for errno
#include<sys/socket.h>
#include<arpa/inet.h>//for inet_aton
#include<netinet/in.h>//for sockaddr_in
#include<sys/types.h>//for lseek
#include<sys/fcntl.h>
#include<netdb.h>
#include<unistd.h>//for lseek

#define BUFLEN 100

int main(int argc,char **argv)
{
  char file[30] = {0};
  int sockfd,target,k;
  char *strs = "正在接收文件";
  struct sockaddr_in s_addr;
  char buf[BUFLEN];
  unsigned int port;

  //建立socket
  if((sockfd = socket(AF_INET,SOCK_STREAM,0)) == -1){
    perror("socket");
    exit(errno);
  }else
    printf("socket create success!\n");
  
  //设置服务器端口
  if(argv[2])
    port = atoi(argv[2]);
  else
    port = 4567;

  //设置服务器ip
  bzero(&s_addr,sizeof(s_addr)); 
  s_addr.sin_family = AF_INET;//AF_INET表示tcp/ip协议族
  s_addr.sin_port = htons(port);//网络字节序
  if(inet_aton(argv[1],(struct in_addr *)&s_addr.sin_addr.s_addr) == 0){//inet_aton将点分十进制字串argv[1]转为32bit的二进制字节串
   perror(argv[1]); 
   exit(errno);
  }

  //开始连接服务器
  if(connect(sockfd,(struct sockaddr*)&s_addr,sizeof(struct sockaddr)) == -1){
    perror("connect");
    exit(errno);
  }else
    printf("connect success!\n");

  //发送文件

  //接收文件
  while((k = read(sockfd,file,sizeof(file))) < 0)
  {
    if((target = open(file,O_RDONLY)) < 0)
    {
      perror("不能打开目标文件!");
      exit(errno);
    }
  }
  strcat(strs,file);
  strcat(strs,"，稍候...");
  write(1,strs,strlen(strs));
  while((k = read(sockfd,buf,sizeof(buf))) > 0)
  {
    write(target,buf,k);
  }
  printf("接收文件成功！");
  close(target);
  close(sockfd);

  return 0;
}
