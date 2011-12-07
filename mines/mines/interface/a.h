#include<gtk/gtk.h>
 
GtkWidget *window,*n_window,*s_window;
GtkWidget *about_game_window;
GtkWidget *scrolled_window;
GtkWidget *menu;
GtkWidget *menu_bar;
GtkWidget *root_menu;
GtkWidget *menu_items;
GtkWidget *vbox,*vbox2,*vbox3;
GtkWidget *hbox;
GtkWidget *label;
GtkWidget *button,*s_button;
GtkWidget *mine_label;
GtkWidget *time_label;
GtkWidget *dialogtest;
GtkWidget *s_image;
GtkWidget *event_box;
GtkWidget *progress_bar;
PangoFontDescription *desc;
 
struct block
{
    gint       count; 
    gint       mark;
    gboolean   mine;  
    gboolean   marked;
    gboolean   opened;
    GtkWidget  *button;
};
 
static struct block *map;
 
static gboolean game_over;
static gint game_time=0;
gint width;
gint height;
gint mines;
static gint opened_count; 
static gint marked_count;
static gint button_size=20;
static int init=0;
static int LEVEL=2; //game level
static time_out_tag=0;
static int score[3];
static char name[3][20];
static int ID;
static int NO;
static p=0;
static GdkColor red= {0,0xffff,0,0};
static GdkColor green={0,0,0xffff,0};
static GdkColor blue={0,0,0,0xffff};
static about_game_times=0;
 
char *to_chinese(char *);
void exit_about(GtkWidget *);
void about_author();
void exit_about_game();
void about_game();
void exit_hero(GtkWidget *);
void mine_hero();
void save_log();
void game_reset();
void open_block(gint , gint );
void mark_block(gint , gint );
void expose_block(gint ,gint );
void enter_callback( GtkWidget *,GtkWidget *);
void h_name();
void read_hero();
void run();
void save_game();
void read_game();
gboolean tick(gpointer );
gboolean on_mouse_click(GtkWidget *, GdkEventButton *, gpointer );
int change_level(gchar *);
int reset();
int mine_map(int );
void sig_segv();
int sys_init();
