/*
 * =====================================================================================
 *
 *       Filename:  mine.c
 *
 *    Description:  扫雷程序。基于GTK+2.0。
 *
 *        Version:  1.0
 *        Created:  09/08/2011 07:39:02 PM
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  Li Jiehui ljiehui0826@gmail.com
 *        Company:  
 *
 * =====================================================================================
 */
//http://www.ush91.com/ArticleShow.asp?ArticleID=478

#include<gtk/gtk.h>


static void destroy(GtkWidget*,gpointer);
static gboolean delete_event(GtkWidget*,GdkEvent*,gpointer);

int main(int argc,char *argv[])
{ 
  GtkWidget *window;//定义窗体
  GtkWidget *button;
  GtkWidget *table;
  GtkWidget *vbox;
  
  GtkWidget *menu_bar;
  GtkWidget *root_menu;
  GtkWidget *menu_items;
  GtkWidget *menu;

  char *values[100] = 
  { " "
  /*  "0","1","2","3","4","5","6","7","8","9",
    "10","11","12","13","14","15","16","17","18","19",
    "20","21","22","23","24","25","26","27","28","29",
    "30","31","32","33","34","35","36","37","38","39",
    "40","41","42","43","44","45","46","47","48","49",
    "50","51","52","53","54","55","56","57","58","59",
    "60","61","62","63","64","65","66","67","68","69",
    "70","71","72","73","74","75","76","77","78","79",
    "80","81","82","83","84","85","86","87","88","89",
    "90","91","92","93","94","95","96","97","98","99",
  */ };

  gtk_init(&argc,&argv);//初始化GTK+库
  
  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);//创建一个新窗体
  gtk_window_set_position(GTK_WINDOW(window),GTK_WIN_POS_CENTER);
  gtk_window_set_default_size(GTK_WINDOW(window),250,180);
  gtk_window_set_title(GTK_WINDOW(window),"Mines");

  gtk_container_set_border_width(GTK_CONTAINER(window),5);//改变窗口大小
  gtk_widget_set_size_request(window,500,500);

  vbox = gtk_vbox_new(TRUE,0);

//menubar
  menu_bar = gtk_menu_bar_new();//创建一个新菜单栏
  gtk_box_pack_start(GTK_BOX(vbox),menu_bar,TRUE,TRUE,0);

//menu Game
  root_menu = gtk_menu_item_new_with_label("Game");//创建菜单根
  gtk_menu_shell_append(GTK_MENU_SHELL(menu_bar),root_menu);//追加到菜单栏中
  menu = gtk_menu_new();//创建一个菜单
  gtk_menu_item_set_submenu(GTK_MENU_ITEM(root_menu),menu);
  menu_items = gtk_menu_item_new_with_label("Begin");//创建一个菜单项
  gtk_menu_shell_append(GTK_MENU_SHELL(menu),menu_items);
  menu_items = gtk_menu_item_new();//添加一条分割线
  gtk_menu_shell_append(GTK_MENU_SHELL(menu),menu_items);
  menu_items = gtk_menu_item_new_with_label("Exit");//创建一个菜单项
  gtk_menu_shell_append(GTK_MENU_SHELL(menu),menu_items);


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
  gtk_container_add(GTK_CONTAINER(window),vbox);

//connect the main window to the destroy and delete-event signals.
  g_signal_connect(G_OBJECT(window),"destroy",G_CALLBACK(destroy),NULL);
  g_signal_connect(G_OBJECT(window),"delete_event",G_CALLBACK(delete_event),NULL);

  gtk_widget_show_all(window);//使所有窗体可见
//gtk_widget_show(vbox);

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
