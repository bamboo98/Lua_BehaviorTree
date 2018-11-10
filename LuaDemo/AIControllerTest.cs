using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using LuaInterface;
using Microsoft.VisualBasic;


namespace LuaDemo
{
    public partial class AIControllerTest : Form
    {
        class Tolua   //这个类用来存放要开放给LUA的函数
        {
            public int sleft, stop;
            AIControllerTest fm1;
            public Tolua(AIControllerTest fm)
            {
                fm1 = fm;
                sleft = fm.Left;
                stop = fm.Top;
            }
            public void ShowMessage(string s)
            {
                MessageBox.Show(s);
            }
            public string GetString(string tip,string top,string defaultstr)
            {
                return Interaction.InputBox(tip, top, defaultstr, sleft+320, stop + 120);
            }
            public void PrintToWindows(string s)
            {
                fm1.textBox1.AppendText(s + "\r\n");
            }
            public void ClearPrint()
            {
                fm1.textBox1.Text="";
            }
        }
        Lua lua;
        Tolua a1;
        
        public AIControllerTest()
        {
            InitializeComponent();
            LoadLuaCode();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
        }

        private void LoadLuaCode()
        {
            lua = new Lua();
            a1 = new Tolua(this);
            lua.RegisterFunction("ShowMessage", a1, a1.GetType().GetMethod("ShowMessage")); //注册函数给LUA
            lua.RegisterFunction("GetString", a1, a1.GetType().GetMethod("GetString")); //注册函数给LUA
            lua.RegisterFunction("PrintToWindows", a1, a1.GetType().GetMethod("PrintToWindows")); //注册函数给LUA
            lua.RegisterFunction("ClearPrint", a1, a1.GetType().GetMethod("ClearPrint")); //注册函数给LUA
            try
            {
                lua.DoFile(@"Main.lua");
            }
            catch (Exception er)
            {
                MessageBox.Show("请修正Main.lua中的错误:" + er.Message);
                Application.Exit();
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            LoadLuaCode();
            object[] obj = new object[1];//接受返回值,1个参数
            LuaFunction func = lua.GetFunction("Main");
            try
            {
                obj = func.Call(new object[]{});
            }
            catch (Exception er)
            {
                MessageBox.Show("请修正Main.lua中的错误:" + er.Message);
                obj = null;
                return;
            }
            finally
            {
                func = null;
            }
            obj = null;
        }

        private void Form1_Move(object sender, EventArgs e)
        {
            a1.stop = Top;
            a1.sleft = Left;
        }
        
    }
}
