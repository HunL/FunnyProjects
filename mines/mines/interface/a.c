#include<gtk/gtk.h>
#include "a.h"
 
int mine_map(int level)
{ 
    //难度选择部分
    if(level != 0)
    {
      LEVEL = level;
      switch(level)
      {
        case 1://难度1：有10*10个方格
          height = width = 10;
          mines = 10;
          break;
        case 3://难度3：有16*30个方格
          height = 16;
          width = 30;
          mines = 99;
          break;
        case 2://难度2：有16*16个方格
        default:
          height = width = 16;
          mines = 40;
          break;
      }
    }

    int i,j,index;
 
    height=width=10;
//    mines=40;
    map=(struct block *)g_malloc0(sizeof(struct block)*width* height);
   
    //vbox
    vbox =gtk_vbox_new(FALSE, 0);
 
    //menubar
    menu_bar = gtk_menu_bar_new ();
    gtk_box_pack_start (GTK_BOX (vbox), menu_bar, FALSE, FALSE, 2);
           
    //menu Game
    root_menu = gtk_menu_item_new_with_label ("Game");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu_bar), root_menu);
    menu = gtk_menu_new ();
    gtk_menu_item_set_submenu (GTK_MENU_ITEM (root_menu), menu);
    menu_items = gtk_menu_item_new_with_label ("Begin");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
 
    menu_items = gtk_menu_item_new ();
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
    menu_items = gtk_menu_item_new_with_label ("Easy");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
   
    menu_items = gtk_menu_item_new_with_label ("Difficulet");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
   
    menu_items = gtk_menu_item_new_with_label ("Hard");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
      
    menu_items = gtk_menu_item_new();
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
    menu_items = gtk_menu_item_new_with_label ("Exit");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
                         
    //menu Help
    menu = gtk_menu_new ();
    root_menu = gtk_menu_item_new_with_label ("Help");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu_bar), root_menu);
    gtk_menu_item_set_submenu (GTK_MENU_ITEM (root_menu), menu);
    menu_items = gtk_menu_item_new_with_label ("About");
    gtk_menu_shell_append (GTK_MENU_SHELL (menu), menu_items);
              
    //hbox
    hbox=gtk_hbox_new(TRUE, 0);
      
    //label:mine
    mine_label=gtk_label_new("0");
    gtk_box_pack_start(GTK_BOX(hbox), mine_label,TRUE, FALSE, 2);
   
    //button:reset
    button=gtk_button_new_with_label("reset");
    gtk_box_pack_start(GTK_BOX(hbox),button,TRUE,FALSE,2);
   
    //label:time
    time_label=gtk_label_new("0");
    gtk_box_pack_start(GTK_BOX(hbox), time_label,TRUE, FALSE, 2);
    gtk_box_pack_start(GTK_BOX(vbox), hbox,FALSE, FALSE, 5);   
   
    for(i=0, index=0; i<height;i++)
    { 
       hbox=gtk_hbox_new(FALSE, 0);
       for(j=0; j<width;j++)
        {
           GtkWidget *button;
           button=gtk_toggle_button_new();//建立不带标号的触发按钮。因为触发按钮是由普通按钮派生而来的，所以所有可以用在普通按钮上的事件和函数都可以用在触发按钮上。并且触发按钮增加了一个信号”toggled(触发)”，当按钮的状态改变时它发送”触发”信号。
           gtk_widget_set_usize(button,40,40);//设定按钮大小
           gtk_box_pack_start(GTK_BOX(hbox),button, FALSE,
              FALSE, 0);//将按钮放在hbox顶部
          
           map[index].button=button;
           index++;
       }
       gtk_box_pack_start(GTK_BOX(vbox), hbox, FALSE, FALSE, 0);
    }
    gtk_container_add(GTK_CONTAINER(window), vbox);
    gtk_widget_show_all(window);
 
    return 0;
}

int start();
void game_reset();
//gboolean on_mouse_click(GtkWidget *,GtkEventButton *,gpointer);
int change(gchar *);

int main(int argc, char **argv)
{ 
    int index;
    gtk_init(&argc, &argv);
   
    window=gtk_window_new(GTK_WINDOW_TOPLEVEL);
    gtk_window_set_title(GTK_WINDOW(window),"mine");
    gtk_window_set_position(GTK_WINDOW(window),GTK_WIN_POS_CENTER);
//    gtk_window_set_default_size(GTK_WINDOW(window),250,180);//设置窗口初始大小
//    gtk_window_set_policy(GTK_WINDOW(window),FALSE,FALSE,TRUE);
    
//    gtk_widget_set_size_request(window,500,500);//设置控件所需要的窗口最小大小
    gtk_container_set_border_width (GTK_CONTAINER(window),5);
    g_signal_connect(G_OBJECT(window), "delete_event",gtk_main_quit, NULL);
 
    mine_map(2);
    
    g_signal_connect(G_OBJECT(menu_items), "activate",GTK_SIGNAL_FUNC(start), NULL);//添加信号处理。点击“Begin”项，游戏重新开始。
//    g_signal_connect(G_OBJECT(button), "button-press-event",G_CALLBACK(on_mouse_click),(gpointer)index);//给地雷区每个方块添加信号响应。鼠标按键信号是“button_press_event”。
    g_signal_connect_swapped(G_OBJECT(menu_items),"activate",GTK_SIGNAL_FUNC(change),"1");//添加难度选择的信号处理函数
    g_signal_connect_swapped(G_OBJECT(menu_items),"activate",gtk_main_quit,NULL);//添加信号处理。点击“exit”时退出游戏。
    g_signal_connect_swapped(G_OBJECT(menu_items),"activate",GTK_SIGNAL_FUNC(about_game),NULL);//添加信号处理。点击“About“弹出一个窗口，显示版本信息。

    gtk_main();
 
    return 0;
}

int start()
{
 gtk_container_remove(GTK_CONTAINER(window),vbox);//将原窗口内的所有构件移除，然后重新绘制。同时调用game_reset()使时间清0，地雷区雷数为初始值。
 mine_map(LEVEL);
 game_reset();
}

void game_reset()
{
  gint size = width * height;
  gint i = 0;
  gchar buf[4];

  game_time = 0;
  g_snprintf(buf,4,"%d",MAX(0,mines-marked_count));//g_snprintf()和g_strdup_printf()，它们的功能与C语言sprintf类似，都是把一串格式输出写进字符串里（常用于数字和字符混合输出到字符串里），但g_snprintf()和g_strdup_printf()更安全。g_snprintf()需要指定目的字符串长度，避免输出越界；g_strdup_printf()则在函数内部自行申请足够的空间存放目的字符串（注意它返回的字符串废弃之后需要用g_free()释放空间）。
  gtk_label_set_text(GTK_LABEL(mine_label),buf);
}

  int change(gchar *data)
{
  int n;

  n = atoi(data);
  gtk_container_remove(GTK_CONTAINER(window),vbox);
  mine_map(n);
  game_reset();
}

  void exit_about(GtkWidget *widget)
{
  gtk_dialog_response(GTK_DIALOG(widget),ID);
  gtk_widget_destroy(widget);
}

void about_game()
{
  GtkWidget *dialog,*label2;
  GtkWidget *button2;
  dialog = gtk_dialog_new();
  gtk_window_set_position(GTK_WINDOW(dialog),GTK_WIN_POS_CENTER);
  gtk_widget_set_usize(dialog,214,117);
  gtk_window_set_policy(GTK_WINDOW(dialog),FALSE,FALSE,FALSE);
  label2 = gtk_label_new("   Mine game!\n"
      "Version : 1.0\n"
      "Copy from Windows Mine\n"
      "Author : L-jiehui\n"
      "Time : 2011.9.10");
  gtk_box_pack_start(GTK_BOX(GTK_DIALOG(dialog)->vbox),label2,TRUE,TRUE,0);
  button2 = gtk_button_new_with_label("OK");
  GTK_WIDGET_SET_FLAGS(button2,GTK_CAN_DEFAULT);
  gtk_signal_connect_object(GTK_OBJECT(button2),"clicked",GTK_SIGNAL_FUNC(exit_about),GTK_OBJECT(dialog));
  gtk_box_pack_start(GTK_BOX(GTK_DIALOG(dialog)->action_area),button2,TRUE,TRUE,0);
  gtk_widget_grab_default(button2);
  gtk_widget_show_all(dialog);
  ID = gtk_dialog_run(GTK_DIALOG(dialog));
}

/*
gboolean on_mouse_click(GtkWidget *widget,GtkEventButton *event,gpointer data)//GtkEventButton对应鼠标按键事件，结构成员event->button等于1对应按下鼠标左键，等于3对应按下鼠标右键。
{
  gint index;
  gint row,col;
  gchar buf[4];

  vbox3 = gtk_vbox_new(FALSE,0);
  gtk_box_pack_start(GTK_BOX(vbox),image,FALSE,FALSE,0);
  
  if(time_out_tag==0)
  {
    time_out_tag = g_timeout_add(1000,(GSourceFunc)tick,NULL);
  }

  if(game_over == TRUE)
    return TRUE;
  
  index = (gint)data;

  switch(event->button)
  {
    case 1:
      row = index/width;
      col = index%width;
      open_block(col,row);
      break;
    case 2:
      break;
    case 3:
      if(map[index].opened == TRUE)
        break;
      if(map[index].marked != TRUE)
      {
        map[index].marked = TRUE;
        gtk_button_set_label(GTK_BUTTON(widget),"@");
        marked_count++;
      }
      else
      {
        map[index].marked = FALSE;
        gtk_button_set_label(GTK_BUTTON(widget),"");
        marked_count--;
      }
      g_snprintf(buf,4,"%d",MAX(0,mines-marked_count));
      gtk_label_set_text(GTK_LABEL(mine_label),buf);
  }
  gtk_toggle_button_set_mode(GTK_TOGGLE_BUTTON(map[index].button),TRUE);

  return TRUE;
}
*/
