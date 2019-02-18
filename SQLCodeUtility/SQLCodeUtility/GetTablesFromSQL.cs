using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;


namespace SQLCodeUtility
{
    class GetTablesFromSQL
    {
        [STAThread]
        static void Main(string[] args)
        {

            //format considerations
            //table1,table2
            //from[table1]
            //join[table1]

            //string query = "from[audit].[gljobrun],[AUDIT].[Region]join[audit].[GLJob]on[JobName]=[JobName]";
            
            string fileFullName = null;
            OpenFileDialog ofd = new OpenFileDialog();
            ofd.ShowDialog();            
            fileFullName = ofd.FileName;

            if (File.Exists(fileFullName) == false)
            {
                MessageBox.Show("No file selected, Process Cancelled");
                return;
            }

            var lines = File.ReadAllLines(fileFullName).ToList();
            var result = (from line in lines
                         where line.Contains("from") ||
                         line.Contains("join")
                         select line).ToList();

            string search_string = null;
            string after_from = null;
            string[] join_split = null;
            List<string> after_join = new List<string>();
            string[] comma_split = null;
            List<string> after_comma = new List<string>();
            string[] on_split = null;
            List<string> before_on = new List<string>();


            foreach (string row in result)
            {

                //check for from
                search_string = "from";
                if (row.Contains(search_string) == true)
                {
                    after_from = row.Substring(row.IndexOf(search_string) + search_string.Length);
                }
                else
                {
                    after_from = row.ToString();
                }

                //check for join
                search_string = "join";
                if (after_from.Contains("join") == true)
                {
                    join_split = after_from.Split(new[] { search_string }, StringSplitOptions.None);
                    foreach (var r in join_split)
                    {
                        //ignore string before join
                        var searchFor = new List<string>();
                        searchFor.Add("left");
                        searchFor.Add("inner");
                        searchFor.Add("right");
                        searchFor.Add("cross");
                        if (searchFor.Any(word => r.Contains(word)) == false)
                        {
                            after_join.Add(r);
                        }
                        
                    }
                }
                else
                {
                    after_join.Add(after_from);
                }

                //check for comma
                search_string = ",";
                foreach (var e in after_join)
                {
                    if (e.Contains(search_string) == true)
                    {
                        comma_split = e.Split(new[] { search_string }, StringSplitOptions.None);
                        foreach (var r in comma_split)
                        {
                            after_comma.Add(r);
                        }
                    }
                    else
                    {
                        after_comma.Add(e);
                    }
                }

                //check for on
                search_string = "on";
                foreach (var e in after_comma)
                {
                    if (e.Contains(search_string) == true)
                    {
                        int on_index = e.IndexOf(search_string);

                        if (Char.IsLetter(e[on_index - 1]) == false && Char.IsLetter(e[on_index + 2]) == false)
                        {
                            on_split = e.Split(new[] { search_string }, StringSplitOptions.None);
                            before_on.Add(on_split[0]);
                        }
                        else
                        {
                            before_on.Add(e);
                        }

                    }
                    else
                    {
                        before_on.Add(e);

                    }
                }
            }

            string str_temp = null;
            List<string> converted_tables = new List<string>();
            
            foreach (string s in before_on)
            {
                //convert .. to .dbo.
                str_temp = s.Replace("..", ".dbo.");
                //trim leading spaces
                str_temp = str_temp.TrimStart();
                //convert tabs to spaces
                str_temp = str_temp.Replace('\t', ' ');
                //remove string after table                  
                bool periodExists = str_temp.Contains(".");
                if (periodExists == true)
                {                    
                    int lastPeriod = str_temp.LastIndexOf('.');
                    bool closeBracketExists = str_temp.Substring(lastPeriod).Contains("]");
                    if (closeBracketExists == true)
                    {
                        int lastBracket = str_temp.LastIndexOf(']');                        
                        str_temp = str_temp.Substring(0, lastBracket + 1);
                        
                    }
                    else
                    {
                        int lastSpace = str_temp.Substring(lastPeriod).IndexOf(' ');
                        int stopIndex = lastPeriod + lastSpace;
                        str_temp = str_temp.Substring(0, stopIndex);

                    }
                }
                else
                {
                    str_temp = str_temp;
                }

                if (string.IsNullOrEmpty(str_temp) == false)
                {
                    converted_tables.Add(str_temp.ToLower()
                        .Replace("[", "")
                        .Replace("]", "")
                        );
                }
                

            }    

            List<string> uniqueTables = converted_tables.Distinct().ToList();
            System.IO.Directory.CreateDirectory(@"c:\temp");
            string OutputFileFullName = @"c:\temp\sql_tables.txt";
            using (TextWriter tw = new StreamWriter(OutputFileFullName))
            {
                foreach (string s in uniqueTables)
                    tw.WriteLine(s);
            }

            System.Diagnostics.Process.Start(@"c:\temp\sql_tables.txt");
        }
    }
}
    