using System;
using System.Drawing;
using System.Windows.Forms;

namespace ComprehensiveExamApp
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            
            // CRITICAL: Must be true for the Form to intercept global keyboard events
            this.KeyPreview = true; 
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // ==========================================
            // 1. COMBOBOX INITIALIZATION & SETUP
            // ==========================================
            // Add items to a ComboBox (e.g., layout view choices)
            comboBoxView.Items.AddRange(new object[] { "LargeIcon", "SmallIcon", "Details", "List", "Tile" });
            comboBoxView.SelectedIndex = 2; // Default to Details view

            // ==========================================
            // 2. LISTBOX INITIALIZATION & SETUP
            // ==========================================
            // Add items to a ListBox and enable multi-selection
            listBox1.Items.AddRange(new object[] { "Apple", "Banana", "Orange", "Grape" });
            listBox1.SelectionMode = SelectionMode.MultiExtended;

            // ==========================================
            // 3. LISTVIEW INITIALIZATION & DETAILS SETUP
            // ==========================================
            // ListView MUST be set to Details view to display columns and subitems
            listView1.View = View.Details;
            
            // Define Column Headers (Name and Width)
            listView1.Columns.Add("ID", 60);
            listView1.Columns.Add("Item Name", 120);
            listView1.Columns.Add("Price", 80);

            // Add a multi-column row using ListViewItem and SubItems
            ListViewItem sampleRow = new ListViewItem(new string[] { "101", "MacBook Pro", "$1299" });
            listView1.Items.Add(sampleRow);
        }

        // ==========================================
        // 4. COMBOBOX EVENT: Changing ListView View
        // ==========================================
        private void comboBoxView_SelectedIndexChanged(object sender, EventArgs e)
        {
            // comboBoxView.Text retrieves the selected string value
            if (comboBoxView.Text == "LargeIcon") listView1.View = View.LargeIcon;
            else if (comboBoxView.Text == "SmallIcon") listView1.View = View.SmallIcon;
            else if (comboBoxView.Text == "Details") listView1.View = View.Details;
            else if (comboBoxView.Text == "List") listView1.View = View.List;
            else if (comboBoxView.Text == "Tile") listView1.View = View.Tile;
        }

        // ==========================================
        // 5. LISTBOX TO LISTVIEW TRANSFER LOGIC
        // ==========================================
        // Backward index loop prevents index-shifting errors when deleting items from ListBox
        private void btnMoveSelected_Click(object sender, EventArgs e)
        {
            for (int i = listBox1.SelectedIndices.Count - 1; i >= 0; i--)
            {
                int selectedIndex = listBox1.SelectedIndices[i];
                string itemText = listBox1.Items[selectedIndex].ToString();

                // Package the string into a multi-column ListViewItem format
                ListViewItem newItem = new ListViewItem(new string[] { "999", itemText, "$0.00" });
                listView1.Items.Add(newItem);

                // Remove the transferred item from the source ListBox
                listBox1.Items.RemoveAt(selectedIndex);
            }
        }

        private void btnClearAll_Click(object sender, EventArgs e)
        {
            listBox1.Items.Clear(); // Clears all items in the ListBox
            listView1.Items.Clear(); // Clears all rows in the ListView
        }

        // ==========================================
        // 6. MOUSE EVENTS & PROPERTIES (`MouseEventArgs`)
        // ==========================================
        private void Form1_MouseMove(object sender, MouseEventArgs e)
        {
            // e.X and e.Y track cursor coordinates live
            lblCoordinates.Text = "X: " + e.X + " | Y: " + e.Y;
        }

        private void pictureBox1_MouseClick(object sender, MouseEventArgs e)
        {
            // e.Button identifies Left, Right, or Middle clicks
            if (e.Button == MouseButtons.Right)
            {
                this.BackColor = Color.White;
            }
            else if (e.Button == MouseButtons.Left)
            {
                this.BackColor = Color.Gray;
            }
        }

        // ==========================================
        // 7. KEYBOARD EVENTS & PROPERTIES (`KeyEventArgs` / `KeyPressEventArgs`)
        // ==========================================
        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            // e.KeyCode checks specific keys
            if (e.KeyCode == Keys.Up)
            {
                // Fonts are immutable; instantiate a new Font object to alter size
                lblTitle.Font = new Font(lblTitle.Font.FontFamily, lblTitle.Font.Size + 2);
            }
            else if (e.KeyCode == Keys.Down)
            {
                lblTitle.Font = new Font(lblTitle.Font.FontFamily, lblTitle.Font.Size - 2);
            }
            // e.Control checks modifier keys combined with KeyData or KeyCode
            else if (e.Control && e.KeyCode == Keys.S)
            {
                MessageBox.Show("Total items currently logged: " + listBox1.Items.Count);
            }
        }

        private void textBoxInput_KeyPress(object sender, KeyPressEventArgs e)
        {
            // e.KeyChar captures individual printed characters
            // Restrict input to letters, spaces, and control keys (like Backspace)
            if (!char.IsLetter(e.KeyChar) && !char.IsWhiteSpace(e.KeyChar) && !char.IsControl(e.KeyChar))
            {
                e.Handled = true; // Cancels/rejects forbidden characters
            }
        }

        // ==========================================
        // 8. MENUSTRIP & BITWISE XOR FONT STYLE TRICK
        // ==========================================
        private void boldToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // Bitwise XOR (^) toggles the style bit on or off without affecting other active styles
            label1.Font = new Font(label1.Font, label1.Font.Style ^ FontStyle.Bold);
        }

        private void italicToolStripMenuItem_Click(object sender, EventArgs e)
        {
            label1.Font = new Font(label1.Font, label1.Font.Style ^ FontStyle.Italic);
        }

        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close(); // Closes the running form application
        }
    }
}

using System;
using System.Drawing;
using System.Windows.Forms;

namespace ComprehensiveExamReference
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            
            // CRITICAL: Must be true for the form to intercept global keyboard events[cite: 1]
            this.KeyPreview = true; 
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // 1. Panel & Visibility Setup (Assignment 4 pattern)[cite: 3]
            panel2.Visible = false;

            // 2. ToolTip Initialization
            toolTip1.SetToolTip(pictureBox1, "Tracking Area");
            toolTip1.SetToolTip(listBox1, "Item Log");

            // 3. ListView Details View & Columns Setup
            listView1.View = View.Details;
            listView1.Columns.Add("Item Name", 120);
            listView1.Columns.Add("Price", 80);
            listView1.Columns.Add("Release Date", 100);

            // Adding multi-column item with SubItems
            ListViewItem laptop = new ListViewItem(new string[] { "MacBook Pro", "$1299", "2026" });
            listView1.Items.Add(laptop);
        }

        // ==========================================
        // 1. MOUSE EVENTS & PROPERTIES (Assignment 5)[cite: 2]
        // ==========================================
        
        private void Form1_MouseMove(object sender, MouseEventArgs e)
        {
            // e.X and e.Y capture cursor coordinates in real time[cite: 2]
            lblCoordinates.Text = "X: " + e.X + ", Y: " + e.Y;
        }

        private void pictureBox1_MouseEnter(object sender, EventArgs e)
        {
            // Ordinary EventArgs used when crossing control borders[cite: 2]
            pictureBox1.BorderStyle = BorderStyle.Fixed3D; 
        }

        private void pictureBox1_MouseLeave(object sender, EventArgs e)
        {
            pictureBox1.BorderStyle = BorderStyle.None; 
        }

        private void pictureBox1_MouseClick(object sender, MouseEventArgs e)
        {
            // e.Button distinguishes Left, Right, or Middle clicks[cite: 2]
            if (e.Button == MouseButtons.Right)
            {
                this.BackColor = Color.White;[cite: 2]
            }
            else if (e.Button == MouseButtons.Left)
            {
                this.BackColor = Color.Gray;[cite: 2]
            }
        }

        // ==========================================
        // 2. KEYBOARD EVENTS & PROPERTIES (Assignment 6)[cite: 1]
        // ==========================================

        private void Form1_KeyDown(object sender, KeyEventArgs e)
        {
            // e.KeyCode: Checks specific key enumerations[cite: 1]
            if (e.KeyCode == Keys.Up)
            {
                // Fonts are immutable; create a new instance to change size[cite: 1]
                lblTitle.Font = new Font(lblTitle.Font.FontFamily, lblTitle.Font.Size + 2);
            }
            else if (e.KeyCode == Keys.Down)
            {
                lblTitle.Font = new Font(lblTitle.Font.FontFamily, lblTitle.Font.Size - 2);[cite: 1]
            }
            else if (e.KeyCode == Keys.C)
            {
                listBox1.Items.Clear();[cite: 1]
            }
            else if (e.KeyCode == Keys.R)
            {
                lblTitle.Text = "Welcome to Philadelphia";[cite: 1]
            }
            // e.Control, e.Shift, e.Alt combined with KeyData/KeyCode for shortcuts[cite: 1]
            else if (e.Control && e.KeyCode == Keys.S)
            {
                MessageBox.Show("Total items: " + listBox1.Items.Count);
            }
        }

        private void Form1_KeyUp(object sender, KeyEventArgs e)
        {
            // Displays the name of the released key[cite: 1]
            lblStatus.Text = "Key Released: " + e.KeyCode.ToString();
        }

        private void textBox1_KeyPress(object sender, KeyPressEventArgs e)
        {
            // e.KeyChar captures printable characters[cite: 1]
            // Restrict input to letters, spaces, and control keys (like Backspace)
            if (!char.IsLetter(e.KeyChar) && !char.IsWhiteSpace(e.KeyChar) && !char.IsControl(e.KeyChar))
            {
                e.Handled = true; // Cancels/rejects the typed character
            }
        }

        // ==========================================
        // 3. LISTBOX & LISTVIEW TRANSFER TRICKS
        // ==========================================

        // Move Selected Items (Backward Index Loop prevents index-shifting bugs)
        private void btnMoveSelected_Click(object sender, EventArgs e)
        {
            for (int i = listBox1.SelectedIndices.Count - 1; i >= 0; i--)
            {
                int index = listBox1.SelectedIndices[i];
                string itemText = listBox1.Items[index].ToString();
                
                listView1.Items.Add(itemText);
                listBox1.Items.RemoveAt(index);
            }
        }

        // Move All Items
        private void btnMoveAll_Click(object sender, EventArgs e)
        {
            foreach (var item in listBox1.Items)
            {
                listView1.Items.Add(item.ToString());
            }
            listBox1.Items.Clear();
        }

        // ==========================================
        // 4. MENUSTRIP & BITWISE XOR FONT STYLE TRICK
        // ==========================================

        private void closeToolStripMenuItem_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void redToolStripMenuItem_Click(object sender, EventArgs e)
        {
            label1.ForeColor = Color.Red;
        }

        private void boldToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // Bitwise XOR (^) flips the style bit on or off without affecting other active styles
            label1.Font = new Font(label1.Font, label1.Font.Style ^ FontStyle.Bold);
        }

        private void italicToolStripMenuItem_Click(object sender, EventArgs e)
        {
            label1.Font = new Font(label1.Font, label1.Font.Style ^ FontStyle.Italic);
        }

        private void underlineToolStripMenuItem_Click(object sender, EventArgs e)
        {
            label1.Font = new Font(label1.Font, label1.Font.Style ^ FontStyle.Underline);
        }
    }
}


