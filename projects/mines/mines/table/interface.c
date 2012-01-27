/*
 * =====================================================================================
 *
 *       Filename:  interface.c
 *
 *    Description:  扫雷界面。基于GTK+2.0。用table画出100个按钮。
 *
 *        Version:  1.0
 *        Created:  09/05/2011 07:39:02 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Li Jiehui ljiehui0826@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */
#include<gtk/gtk.h>

/* 
struct block
{
  gint count;//表示一个点周围有多少个雷
  gboolean mine;//这个点是否藏有雷
  gboolean marked;//是否被标记有雷
  gboolean opened;//是否被掀开
  GtkWidget *button;
}

static struct block *map;//整个地雷区图
static gint size;//整个地图区的大小
static gint width = 10;//雷区的宽度
static gint height = 10;//雷区的高度
static gint button_size = 25;//每个按钮的大小

static gint i = 0,j,index;
*/

static void destroy(GtkWidget*,gpointer);
static gboolean delete_event(GtkWidget*,GdkEvent*,gpointer);
//void PackNewButton_v(GtkWidget *vbox,char *szLabel);
//void PackNewButton_h(GtkWidget *hbox,char *szLabel);

int main(int argc,char *argv[])
{ 
  GtkWidget *window;//定义窗体
//          *vbox,//定义竖组装盒
//          *hbox1,//定义横组装盒
//          *hbox2;//定义横组装盒
//          *label;
  GtkWidget *button;
  GtkWidget *table;
  
  char *values[100] = 
  {
    "0","1","2","3","4","5","6","7","8","9",
    "10","11","12","13","14","15","16","17","18","19",
    "20","21","22","23","24","25","26","27","28","29",
    "30","31","32","33","34","35","36","37","38","39",
    "40","41","42","43","44","45","46","47","48","49",
    "50","51","52","53","54","55","56","57","58","59",
    "60","61","62","63","64","65","66","67","68","69",
    "70","71","72","73","74","75","76","77","78","79",
    "80","81","82","83","84","85","86","87","88","89",
    "90","91","92","93","94","95","96","97","98","99",
   };

  gtk_init(&argc,&argv);//初始化GTK+库
  
  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);//创建一个新窗体
  gtk_window_set_position(GTK_WINDOW(window),GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window),250,180);
  gtk_window_set_title(GTK_WINDOW(window),"Mines");

  gtk_container_set_border_width(GTK_CONTAINER(window),50);//改变窗口大小
  gtk_widget_set_size_request(window,500,500);
/*  vbox = gtk_vbox_new(FALSE,0);//创建竖组装盒
  hbox1 = gtk_hbox_new(FALSE,0);//创建横组装盒
  hbox2 = gtk_hbox_new(FALSE,0);//创建横组装盒
*/
/* 
  PackNewButton_v(vbox,"Button1");//调用创建按钮函数
  PackNewButton_v(vbox,"Button2");//调用创建按钮函数
  PackNewButton_v(vbox,"Button3");//调用创建按钮函数
  PackNewButton_v(vbox,"Button4");//调用创建按钮函数
  PackNewButton_v(vbox,"Button5");//调用创建按钮函数
  PackNewButton_v(vbox,"Button6");//调用创建按钮函数
  PackNewButton_v(vbox,"Button7");//调用创建按钮函数
  PackNewButton_v(vbox,"Button8");//调用创建按钮函数
  PackNewButton_v(vbox,"Button9");//调用创建按钮函数
  PackNewButton_v(vbox,"Button10");//调用创建按钮函数*/
/* 
  PackNewButton_h(hbox,"Button-1");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-2");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-3");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-4");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-5");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-6");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-7");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-8");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-9");//调用创建按钮函数
  PackNewButton_h(hbox,"Button-10");//调用创建按钮函数
*/  
//connect the main window to the destroy and delete-event signals.

  table = gtk_table_new(10,10,TRUE);
  gtk_table_set_row_spacings(GTK_TABLE(table),1);
  gtk_table_set_col_spacings(GTK_TABLE(table),1);

  int i = 0;
  int j = 0;
  int pos = 0;

  for(i = 0;i < 10;i++)
  {
    for(j = 0;j < 10;j++)
    {
      button = gtk_button_new_with_label(values[pos]);
      gtk_table_attach_defaults(GTK_TABLE(table),button,j,j+1,i,i+1);
      pos++;
    }
  }

  gtk_container_add(GTK_CONTAINER(window),table);

  g_signal_connect(G_OBJECT(window),"destroy",G_CALLBACK(destroy),NULL);
  g_signal_connect(G_OBJECT(window),"delete_event",G_CALLBACK(delete_event),NULL);

//Create a new GtkLabel widget that is selectable.
//  label = gtk_label_new("MinesSweepGame");
//  gtk_label_set_selectable(GTK_LABEL(label),TRUE);

//  gtk_container_add(GTK_CONTAINER(window),label);//将label放入窗体
/*  gtk_container_add(GTK_CONTAINER(window),vbox);//将竖组装盒放入窗体
  gtk_box_pack_start(GTK_BOX(vbox),hbox1,FALSE,FALSE,0);
  gtk_box_pack_end(GTK_BOX(vbox),hbox2,FALSE,FALSE,0);*/
//  gtk_container_add(GTK_CONTAINER(window),hbox);//将横组装盒放入窗体
/* button = gtk_button_new_with_label("button");
gtk_box_pack_start(GTK_BOX(hbox1),button,FALSE,FALSE,0);
gtk_box_pack_end(GTK_BOX(hbox2),button,FALSE,FALSE,0);*/
//  gtk_widget_show(box);//使组装盒可见
  gtk_widget_show_all(window);//使所有窗体可见
//  gtk_widget_show(window);//使窗体可见

  gtk_main();
  return 0;
}

//Stop the GTK+ main loop function when the window is destroy.
  static void destroy(GtkWidget *window,gpointer data)
{ 
  gtk_main_quit();
}

//Return FALSE to destroy the widget.
  static gboolean delete_event(GtkWidget *window,GdkEvent *event,gpointer data)
{
  return FALSE;
}
/* 
  void PackNewButton_v(GtkWidget *vbox,char *szLabel)
{ 
  GtkWidget *button,*hbox;//定义按钮
  hbox = gtk_hbox_new(FALSE,0);//创建横组装盒
  button = gtk_button_new_with_label(szLabel);//创建带标号的按钮
  gtk_box_pack_start(GTK_BOX(vbox),hbox,FALSE,FALSE,0);//把横组装盒加入竖组装盒
  gtk_box_pack_start(GTK_BOX(vbox),button,FALSE,FALSE,0);//把按钮加入组装盒
  gtk_widget_show(hbox);//使按钮可见
}
*/
/*
  void PackNewButton_h(GtkWidget *hbox,char *szLabel)
{
  GtkWidget *button;//定义按钮
  button = gtk_button_new_with_label(szLabel);//创建带标号的按钮
  gtk_box_pack_start(GTK_BOX(hbox),button,FALSE,FALSE,0);//把按钮加入组装盒
  gtk_widget_show(button);//使按钮可见
}*/
