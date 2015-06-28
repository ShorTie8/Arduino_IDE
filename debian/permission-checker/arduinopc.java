/*
arduino permission checker prompts the user about required device permissions
Copyright (C) 2012 Scott Howard <showard@debian.org>

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
//javac Example.java
//jar cfe Example.jar Example *.class
//java -jar Example.jar

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JLabel;
import javax.swing.SwingUtilities;


public class arduinopc extends JFrame {

    public arduinopc() {
        initUI();
    }

    public final void initUI() {

       JPanel panel = new JPanel();
       getContentPane().add(panel);

//       panel.setLayout(null);

       JButton ignoreButton = new JButton("Ignore");
       //ignoreButton.setBounds(50, 60, 80, 30);
       ignoreButton.addActionListener(new ActionListener() {
           public void actionPerformed(ActionEvent event) {
               System.exit(0);
          }
       });

       JButton addButton = new JButton("Add");
       //addButton.setBounds(150, 60, 80, 30);
       addButton.addActionListener(new ActionListener() {
           public void actionPerformed(ActionEvent event) {
               System.exit(1);
          }
       });

        //JLabel label = new JLabel("<html>You need to be a member of the \"dailout\"<br>group to upload code to an Arduino<br>microcontroller over the USB or<br>serial ports.<br></html>");
	//label.setBounds(10,10,300,100);
        panel.add(new JLabel("<html>You need to be added to the \"dialout\"<br>group to upload code to an Arduino<br>microcontroller over the USB or<br>serial ports.<br><br>Click \"Add\" below to be added.<br><br>You must log out and log in again<br>before any group changes<br>will take effect.</html>", JLabel.CENTER));
        //label.setFont(new Font("Georgia", Font.PLAIN, 14));
       //label.setForeground(new Color(50, 50, 25));
//label.setOpaque(true);


       //panel.add(label);//, BorderLayout.CENTER);
       panel.add(ignoreButton);
       panel.add(addButton);



       setTitle("Arduino Permission Checker");
       setSize(300, 250);
       setLocationRelativeTo(null);
       setDefaultCloseOperation(EXIT_ON_CLOSE);
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                arduinopc ex = new arduinopc();
                ex.setVisible(true);
            }
        });
    }
}
