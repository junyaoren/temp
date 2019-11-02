import java.sql.Connection;
import java.sql.SQLException;
import java.sql.DriverManager;

import java.io.IOException;
import java.sql.*;


public class DatabaseConnTest {


  public static void main(String[] args) {
    System.out.println("haha");

    try {
      Class.forName("com.mysql.cj.jdbc.Driver");
      Connection conn = DriverManager.getConnection(
              "jdbc:mysql://127.0.0.1:3306/new?useUnicode=true&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC", "root", "07shenjingRJY");
      System.out.println("YES");
    }



     catch (SQLException e) {
      System.err.format("SQL State: %s\n%s", e.getSQLState(), e.getMessage());
    } catch (Exception e) {
      e.printStackTrace();
    }

  }
}

