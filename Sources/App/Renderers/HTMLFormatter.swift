////
//  7D50DB3F-C4B8-49ED-8CDD-B89608CB808E: 8:56 AM 8/19/23
//  HTMLFormatter.swift by Gab
//
//  Based off of https://github.com/QuietMisdreavus/swift-markdown/ 's pull request

import Foundation
import Markdown

public struct HTMLFormatter: MarkupWalker {
    public var result = ""

    public static func format(_ markup: Markup) -> String { // convenience
        var walker = HTMLFormatter()
        walker.visit(markup)
        return walker.result
    }
    mutating func wrap(_ tag: String, _ content: String = "") { result += "<\(tag)>\(content)</\(tag)>" }
    
    // MARK: Block Visitors
    public mutating func visitBlockQuote(_ blockQuote: BlockQuote) { result += "<blockquote>\n"; descendInto(blockQuote); result += "</blockquote>\n" }
    public mutating func visitCodeBlock(_ codeBlock: CodeBlock) { result += "<pre><code\(codeBlock.language != nil ? " class=\"language-\(codeBlock.language!)\"" : "")>\(codeBlock.code)</code></pre>\n" }
    public mutating func visitHeading(_ heading: Heading) { result += "<h\(heading.level)>\(heading.plainText)</h\(heading.level)>\n" }
    public mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) { result += "<hr />\n" }
    public mutating func visitHTMLBlock(_ html: HTMLBlock) { result += html.rawHTML }
    public mutating func visitListItem(_ listItem: ListItem) { result += "<li>\(listItem.checkbox != nil ? "<input type=\"checkbox\" disabled=\"\"\(listItem.checkbox! == .checked ? " checked=\"\"" : "") />" : "")"; descendInto(listItem); result += "</li>\n" }
    public mutating func visitOrderedList(_ orderedList: OrderedList) { result += "<ol start=\"\(orderedList.startIndex)\">\n"; descendInto(orderedList); result += "</ol>\n" }
    public mutating func visitUnorderedList(_ unorderedList: UnorderedList) { result += "<ul>\n"; descendInto(unorderedList); result += "</ul>\n" }
    public mutating func visitParagraph(_ paragraph: Paragraph) { result += "<p>"; descendInto(paragraph); result += "</p>\n" }
    
    // MARK: Inline Visitors
    public mutating func visitInlineCode(_ inlineCode: InlineCode) { wrap("code", inlineCode.code) }
    public mutating func visitEmphasis(_ emphasis: Emphasis) { wrap("em", emphasis.plainText) }
    public mutating func visitStrong(_ strong: Strong) { wrap("strong", strong.plainText) }
    public mutating func visitImage(_ image: Image) { result += "<img\(image.source != nil ? " src=\"\(image.source!)\"" : "")\(image.title != nil ? " title=\"\(image.title!)\"" : "") />" }
    public mutating func visitInlineHTML(_ inlineHTML: InlineHTML) { result += inlineHTML.rawHTML }
    public mutating func visitLineBreak(_ lineBreak: LineBreak) { result += "<br />\n" }
    public mutating func visitSoftBreak(_ softBreak: SoftBreak) { result += "\n" }
    public mutating func visitLink(_ link: Link) { result += "<a\(link.destination != nil ? " href=\"\(link.destination!)\"" : "")>"; descendInto(link); result += "</a>" }
    public mutating func visitText(_ text: Text) { result += text.string }
    public mutating func visitStrikethrough(_ strikethrough: Strikethrough) { wrap("del", strikethrough.plainText) }
    public mutating func visitSymbolLink(_ symbolLink: SymbolLink) { if let content = symbolLink.destination { wrap("code", content) } }
    public mutating func visitInlineAttributes(_ attributes: InlineAttributes) {
        result += "<span data-attributes=\"\(attributes.attributes.replacingOccurrences(of: "\"", with: "\\\""))\""
        
        struct Parsed: Decodable { var `class`: String }
        
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        
        if let parsed = try? decoder.decode(Parsed.self, from: "{\(attributes.attributes)}".data(using: .utf8)!) {
            result += " class\"\(parsed)\""
        }
        
        result += ">"; descendInto(attributes); result += "</span>"
    }
    
    // MARK: Table Visitors
    // Some data that we need to transfer over visitations
    // We can't edit function arguments, so we can't pass
    // in information thats in functional style
    var tableInHead = false // Are we visiting a table heading?
    var tableAlignment: [Table.ColumnAlignment?] = [] // What are the alignment rules for the current visited table
    var tableCurrent = 0 // What is our current table column
    
    public mutating func visitTable(_ table: Table) { result += "<table>\n"; tableAlignment = table.columnAlignments; descendInto(table); result += "</table>\n" }
    public mutating func visitTableHead(_ tableHead: Table.Head) { result += "<thead>\n<tr>\n"; tableInHead = true; tableCurrent = 0; descendInto(tableHead); tableInHead = false; result += "</tr>\n</thead>\n" }
    public mutating func visitTableBody(_ tableBody: Table.Body) { if !tableBody.isEmpty { result += "<tbody>\n"; descendInto(tableBody); result += "</tbody>\n" } }
    public mutating func visitTableRow(_ tableRow: Table.Row) { result += "<tr>\n"; tableCurrent = 0; descendInto(tableRow); result += "</tr>\n" }
    public mutating func visitTableCell(_ tableCell: Table.Cell) { result += "<\(tableInHead ? "th": "td")\(tableAlignment[tableCurrent] != nil ? " align=\"\(tableAlignment[tableCurrent]!)\"" : "")\(tableCell.rowspan > 1 ? " rowspan=\"\(tableCell.rowspan)\"" : "")\(tableCell.colspan > 1 ? " colspan=\"\(tableCell.colspan)\"" : "")>"; tableCurrent += 1; descendInto(tableCell); result += "</\(tableInHead ? "th": "td")>\n" }
    
}
