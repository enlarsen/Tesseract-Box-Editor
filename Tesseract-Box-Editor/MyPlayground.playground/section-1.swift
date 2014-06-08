// Playground - noun: a place where people can play

import Cocoa

let fileText = NSString.stringWithContentsOfFile("/Volumes/Media/Movies/SWIMMING_POOL/VIDEO_TS/pgm-0/italic/tess/eng.swim.exp0.box", encoding: NSUTF8StringEncoding, error: nil)

if let text = fileText
{
    text.enumerateLinesUsingBlock({line, stop in

        let scanner = NSScanner(string: line)
        

        })
}
