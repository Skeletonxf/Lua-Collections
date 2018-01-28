import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * A class to build documentation from particularly formatted Lua files
 */
public class DocumentationBuilder {

    private final Path path;
    private final String name;
    private final String luaCode;

    public DocumentationBuilder(Path path, String name, String luaCode) {
        this.path = path;
        this.name = name;
        this.luaCode = luaCode;
    }

    public static void main(String[] args) {
        try (Stream<Path> s = Files.walk(Paths.get("L-C/"), 10)) {
            s.filter(p -> !Files.isDirectory(p))
            .map(DocumentationBuilder::parsePath)
            .filter(Optional::isPresent)
            .map(Optional::get)
            .forEach(d -> d.writeFile());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static Optional<DocumentationBuilder> parsePath(Path path) {
        try {
            return Optional.of(new DocumentationBuilder(
                    Paths.get("docs/" + path.getFileName().toString() + ".md"),
                    path.getFileName().toString(),
                    Files.readAllLines(path).stream()
                    .map(DocumentationBuilder::trim)
                    .reduce("", String::concat)));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Reading file " + path.getFileName() + " failed");
            return Optional.empty();
        }
    }

    public void writeFile() {
        System.out.println("Writing to file " + path.getFileName());
        try {
            Files.write(path, Collections.singletonList(generateDocumentation()),
                    Charset.defaultCharset(),
                    StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING);
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Writing to file failed");
        }
    }

    /**
     * Trims a string to remove trailing whitespace
     * but avoids removing the final newline
     * @param string string to trim
     * @return trimmed string
     */
    public static String trim(String string) {
        return string.trim() + "\n";
    }

    /**
     * Finds all matches for the regex
     * where these match in the lua code
     */
    private List<String> findMatches(String regex) {
        List<String> matches = new ArrayList<>();
        Matcher matcher = Pattern.compile(regex, Pattern.DOTALL).matcher(luaCode);
        while (matcher.find()) {
            String match = matcher.group();
            matches.add(match);
        }
        return matches;
    }

    /**
     * Matches opening of _DESCRIPTION field in headers
     */
    private final String DESCRIPTION_HEADER = "_DESCRIPTION \\= ";
    /**
     * Matches shortest possible string between [[ and ]]
     */
    private final String COMMENT_BLOCK = "(\\[\\[)(.*?)(\\]\\])";

    /**
     * Matches all -- documentation above functions
     */
    private final String METHOD = "\\-\\-([a-zA-Z0-9 ,->\\(\\):`\"'\\{\\}\\[\\]=_]*\\n)*?"
            + "function([a-zA-Z0-9.,_ ]*)\\(([a-zA-Z0-9., ]*)\\)";

    public CharSequence generateDocumentation() {
        StringBuilder stringBuilder = new StringBuilder();
        // File name as title
        stringBuilder.append("# ").append(name).append("\n");
        findMatches(DESCRIPTION_HEADER + COMMENT_BLOCK).forEach(block -> {
            Matcher matcher = Pattern.compile(
                    COMMENT_BLOCK,
                    Pattern.DOTALL).matcher(block);
            matcher.find();
            String description = matcher.group();
            stringBuilder.append(description.substring(2, description.length() - 2));
            stringBuilder.append("\n");
        });
        findMatches(METHOD).forEach(block -> {
            List<String> methodDoc = new ArrayList<>(Arrays.asList(
                    block.replaceAll("\\-\\-", "") // remove -- at start of each line
                    .split("\n")));
            // remove trailing whitespace on each line
            methodDoc = methodDoc.stream()
                    .map(DocumentationBuilder::trim)
                    .collect(Collectors.toList());
            methodDoc.add(0, 
                    "## `" + methodDoc.get(methodDoc.size() - 1).replace("\n", "`\n"));
            methodDoc.remove(methodDoc.size() - 1);
            stringBuilder.append(methodDoc.stream()
                    .reduce("", String::concat)).append("\n");
        });
        return stringBuilder.toString();
    }
}
