//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"
var s:[Float] = [1,2,3,5]
let n:Float = 6
if s.count == 0 {s[0] = n}
else if n < s[0] {s.insert(n, at: 0)}
else if n > s.last! {s.append(n)}
else {
    for i in 0...s.count-2 {
    if n > s[i] && n < s[i+1]{
        s.insert(n, at: i+1)
    }

}
}
print(s)
