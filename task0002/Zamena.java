import java.io.*;
import java.nio.file.*;
/*
��������� �������� ��� ��������� ������ ��� ������ �� ������ � mp3 �������������
����� ���� �������� ��������
������ txt ��� ������ ������ ��� �������.
*/
public class Zamena {

	public static void main(String[] args) throws IOException {
		BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
		System.out.println("������ ���� ��� ����� ���� �����");
		String fileDir = reader.readLine();
		reader.close();
		
		if(Files.exists(Paths.get(fileDir))) {
			System.out.println("���������� ����� ���� " + fileDir);
			if(args.length > 0) {

			switch(args[0]) {
			
			case "txt":
			File dir = new File(fileDir);
			File[] txtFiles = dir.listFiles(new TxtFilenameFilter());
			int i = 0;
			for(File txtFile : txtFiles) {
				System.out.println(txtFile.getAbsolutePath());
				
				StringBuilder sb = new StringBuilder();
				sb.append(Paths.get(txtFile.getAbsolutePath()).getParent());
				sb.append("\\0");
				sb.append(i++);
				sb.append("_");
				sb.append(Paths.get(txtFile.getAbsolutePath()).getFileName());
				
				File destFile = new File(sb.toString()); 
				
				txtFile.renameTo(destFile);
				sb.delete(0, sb.length());
			}
			break;
			
			case "mp3":
			File dir2 = new File(fileDir);
			File[] mp3Files = dir2.listFiles(new Mp3FilenameFilter());
			int i2 =0;
			for(File mp3File : mp3Files) {
				System.out.println(mp3File.getAbsolutePath());
				StringBuilder sb = new StringBuilder();
				sb.append(Paths.get(mp3File.getAbsolutePath()).getParent());
				sb.append("\\0");
				sb.append(i2++);
				sb.append("_");
				sb.append(Paths.get(mp3File.getAbsolutePath()).getFileName());
				
				File destFile = new File(sb.toString()); 
				
				mp3File.renameTo(destFile);
				sb.delete(0, sb.length());
				
			}
			break;
			case "del":
				File dir3 = new File(fileDir);
				File[] DelFiles = dir3.listFiles(new DelFilenameFilter());
				for(File DelFile : DelFiles) {
					System.out.println(DelFile.getAbsolutePath());
				
					StringBuilder sb = new StringBuilder();
					sb.append(Paths.get(DelFile.getAbsolutePath()).getParent());
					sb.append("\\");
					//sb.append(i2++);
					//sb.append("_");
					String str = Paths.get(DelFile.getAbsolutePath()).getFileName()+"";
					sb.append(str.replaceAll("\\d+\\_", ""));
					
					File destFile = new File(sb.toString()); 
					
					DelFile.renameTo(destFile);
					sb.delete(0, sb.length());
				
				}
				
				break;
			default:
                System.out.println("����� ������������ ��������� txt ��� mp3 ��� del ����� �������");
			}
			
			} else 
				System.out.println("����������� ��������� �������� (txt,mp3,del)");
		}
	}
}
	

