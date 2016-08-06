
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
  int k,sockfd,source,newfd;
  char file[30]={0};
  struct sockaddr_in s_addr,c_addr;
  char buf[BUFLEN];
  socklen_t len;
  unsigned int port,listnum;

  printf("输入要传输的文件名：");
  scanf("%s",file);
  if((source = open(file,O_RDONLY)) < 0)
  {
    perror("源文件打开出错");
    exit(1);
  }
  printf("在传送文件，稍候...");

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
  
  //设置侦听队列长度
  if(argv[3])
    listnum = atoi(argv[3]);
  else
    listnum = 3;
  
  //设置服务器ip
  bzero(&s_addr,sizeof(s_addr));
  s_addr.sin_family = AF_INET;
  s_addr.sin_port = htons(port);
  if(argv[1])
    s_addr.sin_addr.s_addr = inet_addr(argv[1]);//inet_addr将点分十进制IP地址字符串转为长整型数
  else
    s_addr.sin_addr.s_addr = INADDR_ANY;//INADDR_ANY将地址指定为0.0.0.0

  //把地址和端口绑定到套接字上
  if((bind(sockfd,(struct sockaddr*)&s_addr,sizeof(struct sockaddr))) == -1){
    perror("bind");
    exit(errno);
  }else
    printf("bind success!\n");

  //侦听本地端口
  if(listen(sockfd,listnum) == -1){
    perror("listen");
    exit(errno);
  }else
    printf("the server is listening!\n");

  while(1)
  {
    printf("**************传送文件开始*******************\n");
    len = sizeof(struct sockaddr);
    if((newfd = accept(sockfd,(struct sockaddr*)&c_addr,&len)) == -1){
      perror("accept");
      exit(errno);
    }
    //lseek(source,0L,0);//每次接受客户机连接，应将用于读的源文件指针移到文件头
    lseek(sockfd,0L,0);//每次接受客户机连接，应将用于读的源文件指针移到文件头
    write(newfd,file,sizeof(file));//发送文件名
    //while((k = read(source,buf,sizeof(buf))) > 0)
    while((k = read(sockfd,buf,sizeof(buf))) > 0)
      write(newfd,buf,k);
    printf("传输完毕!");
    close(newfd);
  }

  //关闭服务器的套接字
  close(sockfd);

  return 0;
}
