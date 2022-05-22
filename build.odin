package main

import "core:fmt"
import "core:os"

Writer :: struct {
	data: [dynamic]u8,
	tag_stack: [dynamic]string,
}

Page :: struct {
	path: string,
	title: string,
	contents: proc(writer: ^Writer),
}

TagAttribute :: struct {
	name: string,
	value: string,
}

write_indent :: proc(writer: ^Writer) {
	for depth in 0..<len(&writer.tag_stack) {
		write_string(writer, "\t")
	}
}

write_string :: proc(writer: ^Writer, str: string) {
	for byte_index in 0..<len(str) {
		append(&writer.data, str[byte_index])
	}
}

write_indented :: proc(writer: ^Writer, str: string) {
	write_indent(writer)
	write_string(writer, str)
	write_string(writer, "\n")
}

clear_writer :: proc(writer: ^Writer) {
	clear(&writer.data)
	clear(&writer.tag_stack)
}

begin_html :: proc(writer: ^Writer) {
	write_string(writer, "<!DOCTYPE html>\n")
}

main :: proc() {
	writer_ := Writer{data = make([dynamic]u8, 0, 1024 * 1024 * 10)}
	writer := &writer_

	pages := []Page{
		{"/", "Code projects", write_code_projects},
		{"/about.html", "About", write_about},
	}

	for page in pages {
		write_page(writer, page.title, page.contents)
		filename := page.path
		if filename == "/" {
			filename = "/index.html"
		}
		os.write_entire_file(fmt.tprintf("build%s", filename), writer.data[:])
		clear_writer(writer)
	}
}

write_page :: proc(writer: ^Writer, title: string, write_content: proc(writer: ^Writer)) {
	begin_html(writer)
	if tag_open(writer, "html", []TagAttribute{{"lang", "en-US"}}) {
		add_head(writer, fmt.tprintf("Sen Khvorov - %s", title))
		if tag_open(writer, "body") {
			add_nav(writer, title)
			if tag_open(writer, "div") {
				if tag_open(writer, "div") {
					write_content(writer)
				}
			}
		}
	}
}

write_code_projects :: proc(writer: ^Writer) {
	if tag_open(writer, "div", []TagAttribute{{"class", "code-project-card"}}) {

		if tag_open(writer, "div") {
			image_attrs := []TagAttribute{
				{"class", "code-project-header-img"},
				{"src", "/learn3d-header.png"},
				{"alt", "software 3d rasteriser header image"},
			}
			if tag_open(writer, "img", image_attrs) {}
		}

		if tag_open(writer, "div") {

			if tag_open(writer, "div", []TagAttribute{{"class", "code-project-card-title"}}) {
				write_indented(writer, "Software 3D renderer")
			}

			if tag_open(writer, "div", []TagAttribute{{"class", "code-project-card-subtitle"}}) {

				item_tag := "span"
				item_attrs := []TagAttribute{{"class", "code-project-card-subtitle-item"}}

				if tag_open(writer, item_tag, item_attrs) {
					write_indented(writer, "Completed: 2022-01-31")
				}

				if tag_open(writer, item_tag, item_attrs) {
					write_indented(writer, "Language: ")
					if tag_open(writer, "a", []TagAttribute{{"href", "https://odin-lang.org"}}) {
						write_indented(writer, "Odin")
					}
				}

				if tag_open(writer, item_tag, item_attrs) {
					if tag_open(writer, "a", []TagAttribute{{"href", "https://github.com/khvorov45/learn3d"}}) {
						write_indented(writer, "Github link")
					}
				}
			}

			if tag_open(writer, "div", []TagAttribute{{"class", "code-project-card-body"}}) {
				if tag_open(writer, "p") {
					write_indented(writer, "A software 3d renderer I wrote in Odin following ")
					if tag_open(writer, "a", []TagAttribute{{"href", "https://pikuma.com/courses/learn-3d-computer-graphics-programming"}}) {
						write_indented(writer, "\"Learn 3d graphics programming from scratch\"")
					}
					write_indented(writer, "course by Gustavo Pezzi.")
				}

				if tag_open(writer, "p") {
					write_indented(
						writer,
						`Can draw textured models (exported as .obj) on the CPU by following steps similar to
						what GPUs do in shaders and internally. Has some extra features not covered in the course.`,
					)
				}
			}
		}
	}
}

write_about :: proc(writer: ^Writer) {
	if tag_open(writer, "p") {
		write_indented(
			writer,
			`Hi! I'm Arseniy (Sen) Khvorov. I work as a statistician at a research centre in Melbourne, Austrialia. 
			I also write code in C and other "systems" lanuages (like Odin).`,
		)
	}
	if tag_open(writer, "p") {
		write_indented(writer, `I discovered my interest in low-level programming in 2021 though`)
		if tag_open(writer, "a", []TagAttribute{{"href", "https://handmadehero.org"}}) {
			write_indented(writer, "Handmade Hero")
		}
		write_indented(
			writer,
			`which I found thanks to youtube reccommeding me Casey Muratori's and Jon Blow's rants on poor software quality.`,
		)
	}
	if tag_open(writer, "p") {
		write_indented(writer, "Email:")
		email := "khvorov45@gmail.com"
		if tag_open(writer, "a", []TagAttribute{{"href", fmt.tprintf("mailto:%s", email)}}) {
			write_indented(writer, email)
		}
		if tag_open(writer, "br") {}
		write_indented(writer, "Github:")
		if tag_open(writer, "a", []TagAttribute{{"href", "https://github.com/khvorov45"}}) {
			write_indented(writer, "@khvorov45")
		}
	}
}

add_head :: proc(writer: ^Writer, title: string) {
	if tag_open(writer, "head") {
		if tag_open(writer, "meta", []TagAttribute{{"charset", "UTF-8"}}) {}
		if tag_open(writer, "meta", []TagAttribute{{"name", "viewport"}, {"content", "width=device-width, initial-scale=1"}}) {}
		if tag_open(writer, "meta", []TagAttribute{{"name", "description"}, {"content", title}}) {}

		if tag_open(writer, "title") {
			write_indented(writer, title)
		}

		// NOTE(khvorov) Stop browsers from requsting favicon
		if tag_open(writer, "link", []TagAttribute{{"rel", "icon"}, {"href", "data:,"}}) {}

		if tag_open(writer, "link", []TagAttribute{{"rel", "stylesheet"}, {"href", "/style.css"}}) {}
	}
}

add_nav :: proc(writer: ^Writer, active: Maybe(string) = nil) {
	if tag_open(writer, "nav") {
		if tag_open(writer, "div") {

			if tag_open(writer, "div") {
				if tag_open(writer, "a", []TagAttribute{{"href", "/"}}) {
					if tag_open(writer, "img", []TagAttribute{{"src", "/AKLogo.png"}, {"alt", "site logo"}}) {}
				}
			}

			if tag_open(writer, "div") {

				if tag_open(writer, "a", _link_attributes("/", active == "Code projects")) {
					write_indented(writer, "Code projects")
				}
				if tag_open(writer, "a", _link_attributes("/about.html", active == "About")) {
					write_indented(writer, "About")
				}
			}
		}
	}
}

@(deferred_in=tag_close)
tag_open :: proc(writer: ^Writer, name: string, attributes: Maybe([]TagAttribute) = nil) -> bool {
	write_indent(writer)
	write_string(writer, "<")
	write_string(writer, name)

	if attributes, some := attributes.([]TagAttribute); some {
		for attribute in attributes {
			tag_attribute(writer, attribute.name, attribute.value)
		}
	}

	write_string(writer, ">\n")


	append(&writer.tag_stack, name)
	return true
}

tag_attribute :: proc(writer: ^Writer, name: string, value: string) {
	write_string(writer, " ")
	write_string(writer, name)
	write_string(writer, "=\"")
	write_string(writer, value)
	write_string(writer, "\"")
}

tag_close :: proc(writer: ^Writer, name: string, attributes: Maybe([]TagAttribute) = nil) {
	tag_stack_name := pop(&writer.tag_stack)
	assert(tag_stack_name == name)
	if !_is_tag_noclose(name) {
		write_indent(writer)
		write_string(writer, "</")
		write_string(writer, tag_stack_name)
		write_string(writer, ">\n")
	}
}

_is_tag_noclose :: proc(name: string) -> bool {
	result := name == "meta" || name == "link" || name == "img" || name == "br"
	return result
}

_link_attributes :: proc(href: string, active: bool) -> []TagAttribute {
	buf := make([]TagAttribute, 2, context.temp_allocator)
	buf[0] = TagAttribute{"href", href}
	result := buf[0:1]
	if (active) {
		buf[1] = TagAttribute{"class", "active"}
		result = buf[:]
	}
	return result
}
