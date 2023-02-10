@main
public struct Example {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(Example().text)
    }
}
