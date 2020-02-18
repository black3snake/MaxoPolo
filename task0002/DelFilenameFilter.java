
import java.io.File;
import java.io.FilenameFilter;
 
public class DelFilenameFilter implements FilenameFilter {
 
    // ��������� ���� (path) � ������m '00_' ������� � ��������������� �������� ������.
    @Override
    public boolean accept(File dir, String name) {
 
        if (name.matches("\\d+\\_.+")) {
            return true;
        }
 
        return false;
    }
 
}