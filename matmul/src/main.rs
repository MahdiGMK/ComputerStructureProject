use regex::Regex;
use std::io::{self, Lines, StdinLock};
fn read(liter: &mut Lines<StdinLock<'_>>) -> bool {
    let mut nn = 0;
    let spc: Regex = Regex::new(r" +").unwrap();
    if let Some(Ok(line)) = liter.next() {
        if let Ok(n) = line.trim().parse() {
            if n > 0 && n <= 512 {
                nn = n;
            }
        }
    }
    if nn == 0 {
        return false;
    }
    let mut vc = vec![];
    for _i in 1..=2 * nn {
        if let Some(Ok(line)) = liter.next() {
            let mut ititer = spc.split(line.trim()).into_iter();
            let mut num = 0;
            while let Some(item) = ititer.next() {
                if let Ok(_) = item.parse::<f32>() {
                    num += 1;
                } else {
                    return false;
                }
            }
            if num != nn {
                return false;
            }
            vc.push(line);
        } else {
            return false;
        }
    }
    println!("{}", nn);
    for item in vc {
        println!("{}", item);
    }
    return true;
}

fn help() {
    eprintln!("Please a valid input according to the following format");
    eprintln!("n (1 <= n <= 512)");
    eprintln!("a0,0 a0,1 ... a0,n-1");
    eprintln!("a1,0 a1,1 ... a1,n-1");
    eprintln!("...");
    eprintln!("an-1,0 an-1,1 ... an-1,n-1");
    eprintln!("b0,0 b0,1 ... b0,n-1");
    eprintln!("b1,0 b1,1 ... b1,n-1");
    eprintln!("...");
    eprintln!("bn-1,0 bn-1,1 ... bn-1,n-1");
}

fn main() {
    let mut liter = io::stdin().lines();

    loop {
        help();
        if read(&mut liter) {
            break;
        }
    }
}
