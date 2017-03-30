package main.java;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.concurrent.Callable;

public class FileImport
{
    public static final String PATH = "C:\\Temp\\jaxb\\rickitest\\inbound";
    public static final String WORKING = "C:\\Temp\\jaxb\\rickitest\\working";
    public static final String PROCESSED = "C:\\Temp\\jaxb\\rickitest\\processed";

    public synchronized File[] getFiles()
    {
        File directory = new File(PATH);
        File[] filesToReturn = directory.listFiles();
        return filesToReturn;
    }

}

final class FileMover implements Callable
{
    private final File[] files;
    private final String pathToMoveTo;
    private final String pathFrom;

    public FileMover(File[] files, String pathToMoveTo, String pathFrom)
    {
        this.files = files;
        this.pathToMoveTo = pathToMoveTo;
        this.pathFrom = pathFrom;
    }

    @Override
    public Boolean call()
    {
        for (File file : files)
        {
            try
            {
                Path movefrom = FileSystems.getDefault().getPath(pathFrom + File.separator + file.getName());
                Path target = FileSystems.getDefault().getPath(pathToMoveTo + File.separator + file.getName());
                Files.move(movefrom, target, StandardCopyOption.REPLACE_EXISTING);
            }
            catch (IOException e)
            {
                e.printStackTrace();
            }
        }
        return true;
    }

    public File[] getFiles()
    {
        return this.files;
    }
}
