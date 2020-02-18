
import java.io.File;
import java.io.FilenameFilter;
 
public class DelFilenameFilter implements FilenameFilter {
 
    // Принимает пути (path) с началоm '00_' возврат к первоначальному значению файлов.
    @Override
    public boolean accept(File dir, String name) {
 
        if (name.matches("\\d+\\_.+")) {
            return true;
        }
 
        return false;
    }
 
}