using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SignalRChat
{
    public partial class chatRoom : System.Web.UI.Page
    {
        

        protected void Page_Load(object sender, EventArgs e)
        {
            string senderName = "";
            //Check Cookies
            if (Request.Cookies["sender-name"] != null)
            {
                txtName.Text = Request.Cookies["sender-name"].Value;
                txtName.ReadOnly = true;

                //Get the sender name
                senderName = Request.Cookies["sender-name"].Value;
            }
                //Declare the connection strings
                string strcon = ConfigurationManager.ConnectionStrings["con"].ConnectionString;

            SqlConnection con = new SqlConnection(strcon);

            //Open Connection
            if (con.State == ConnectionState.Closed)
            {
                con.Open();
            }

            string sql = "SELECT TOP 100 * FROM ChatMessages";

            //Connect to the database
            SqlCommand cmd = new SqlCommand(sql, con);

            SqlDataReader dr = cmd.ExecuteReader();

            //Open tag of UL
            ltrDiscussion.Text = "<ul class='discussion-content' id='discussion'>";

            while (dr.Read())
            {
                if(senderName == dr["sender_name"].ToString())
                {
                    ltrDiscussion.Text = ltrDiscussion.Text +
               "<li><strong>(You) " + dr["sender_name"] + " [" + dr["sent_time"] + "]</strong>: " + dr["chat_content"] + "</li>";
                }
                else
                {
                    ltrDiscussion.Text = ltrDiscussion.Text +
               "<li><strong>" + dr["sender_name"] + " [" + dr["sent_time"] + "]</strong>: " + dr["chat_content"] + "</li>";
                }
               
            }

            //Close tag of UL
            ltrDiscussion.Text = ltrDiscussion.Text + "</ul>";

            //Close connection
            con.Close();
        }

        [WebMethod]
        public static string submit(string chat_content, string sender_name)
        {

            //Declare the connection strings
            string strcon = ConfigurationManager.ConnectionStrings["con"].ConnectionString;

            SqlConnection con = new SqlConnection(strcon);

            //Open Connection
            if (con.State == ConnectionState.Closed)
            {
                con.Open();
            }

            string sql = "INSERT INTO ChatMessages(chat_content, sender_name, sent_time, created_at) " +
                             "VALUES(@chat_content, @sender_name, @sent_time, @created_at)";

            //Connect to the database
            SqlCommand cmd = new SqlCommand(sql, con);

            string sent_time = DateTime.Now.ToString("dd MMMM yyyy h:mm tt");

            //Insert parameters
            cmd.Parameters.AddWithValue("@chat_content", chat_content);
            cmd.Parameters.AddWithValue("@sender_name", sender_name);
            cmd.Parameters.AddWithValue("@sent_time", sent_time);
            cmd.Parameters.AddWithValue("@created_at", DateTime.Now);

            //Execute the queries
            cmd.ExecuteNonQuery();

            //Close connection
            con.Close();

            return sent_time;
        }
    }
}