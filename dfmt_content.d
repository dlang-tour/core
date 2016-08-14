#!/usr/bin/env rdmd

import std.process;
import std.string;
import std.file;
import std.algorithm;
import std.array;
import std.stdio;

immutable MAX_LINE_LENGTH = 48;

string dfmtSource(string source, string filename)
{
	static command = ["dfmt", "--max_line_length=%s".format(MAX_LINE_LENGTH),
		"--soft_max_line_length=%s".format(MAX_LINE_LENGTH), "-t", "space", "--indent_size=4" ];
	auto pipes = pipeProcess(command);
	pipes.stdin.write(source);
	pipes.stdin.flush();
	pipes.stdin.close();

	if (wait(pipes.pid) != 0) {
		writeln("Running ", command, " exited with an error:");
		pipes.stderr.byLine.each!writeln;
		throw new Exception("Failed to format source of " ~ filename ~ ".");
	}

	string[] formatted;
	foreach (line; pipes.stdout.byLine)
		formatted ~= line.idup;
	return formatted.join("\n");
}

auto extractSource(string contents)
{
	auto a = contents.find("## {SourceCode}").find("```d");
	if (!a.empty)
		return a[4 .. $].findSplitBefore("```")[0];
	return "";
}

void main()
{
	auto contentDirectory = "public/content";
	foreach(string filename; dirEntries(contentDirectory, SpanMode.depth)) {
		if (isDir(filename) || !filename.endsWith(".md"))
			continue;

		writeln("Formatting ", filename, "...");
		auto contents = cast(string)read(filename).idup;
		auto source = contents.extractSource;
		if (source.empty) {
			writeln("Skipping because no source code found.");
			continue;
		}
		auto formatted = source.dfmtSource(filename);
		contents = contents.replace(source, "\n" ~ formatted ~ "\n");
		auto file = File(filename, "w");
		file.write(contents);
	}
}
