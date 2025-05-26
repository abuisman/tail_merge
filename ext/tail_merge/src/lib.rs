use magnus::{
    define_module, function, prelude::*, Error, RArray, RHash, RString, Ruby, Value,
};
use rustui_merge::merge::tw_merge;

fn merge_tailwind_classes(args: &[Value]) -> Result<RString, Error> {
    // ---------- 1. arity ----------------------------------------------------
    if args.is_empty() || args.len() > 2 {
        return Err(Error::new(
            magnus::exception::arg_error(),
            "wrong number of arguments (expected 1 or 2)",
        ));
    }

    // ---------- 2. collect class tokens ------------------------------------
    let mut tokens = Vec::<String>::new();
    let is_string_input = matches!(args[0].clone().try_convert::<RString>(), Ok(_));
    match args[0].clone().try_convert::<RString>() {
        Ok(rstr) => tokens.extend(rstr.to_string()?.split_whitespace().map(str::to_owned)),
        Err(_) => {
            let rarray: RArray = args[0].try_convert()?;
            for v in rarray.each() {
                let s: RString = v?.try_convert()?;
                tokens.push(s.to_string()?);
            }
        }
    }

    // Early returns for simple cases
    if is_string_input {
        let rstr: RString = args[0].clone().try_convert()?;
        let s = rstr.to_string()?;
        if !s.contains(' ') {
            // Single class string, return as-is
            return Ok(RString::new(&s));
        }
    } else {
        // Array input
        if tokens.is_empty() {
            return Ok(RString::new(""));
        }
        if tokens.len() == 1 {
            return Ok(RString::new(&tokens[0]));
        }
    }

    // ---------- 3. extract options -----------------------------------------
    let mut prefix: Option<String> = None;
    let mut separator: Option<String> = None;

    if args.len() == 2 {
        let rhash: RHash = args[1].try_convert()?;
        let ruby = Ruby::get().unwrap();

        if let Some(v) = rhash.get(ruby.to_symbol("prefix")) {
            let s: RString = v.try_convert()?;
            prefix = Some(s.to_string()?);
        }
        if let Some(v) = rhash.get(ruby.to_symbol("separator")) {
            let s: RString = v.try_convert()?;
            separator = Some(s.to_string()?);
        }
    }

    // ---------- 4. merge ----------------------------------------------------
    let merged = if let Some(pref) = prefix {
        // split based on whether the last segment starts with the prefix
        let mut with_pref = Vec::new();
        let mut without_pref = Vec::new();

        for t in tokens {
            let base = t.rsplit_once(':').map(|(_, b)| b).unwrap_or(&t);
            if base.starts_with(&pref) {
                // strip prefix after variant(s)
                let stripped = if let Some((v, b)) = t.rsplit_once(':') {
                    format!("{}:{}", v, &b[pref.len()..])
                } else {
                    (&t[pref.len()..]).to_owned()
                };
                with_pref.push(stripped);
            } else {
                without_pref.push(t);
            }
        }

        let mut out = Vec::new();
        if !without_pref.is_empty() {
            out.extend(
                tw_merge(without_pref.join(" "))
                    .split_whitespace()
                    .map(str::to_owned),
            );
        }
        if !with_pref.is_empty() {
            out.extend(
                tw_merge(with_pref.join(" "))
                    .split_whitespace()
                    .map(|s| {
                        // re-attach prefix
                        if let Some((v, b)) = s.rsplit_once(':') {
                            format!("{}:{}{}", v, &pref, b)
                        } else {
                            format!("{}{}", pref, s)
                        }
                    }),
            );
        }
        out.join(" ")
    } else if separator.is_some() {
        // at the moment we can't apply per-call separators without global state;
        // fall back to the default behaviour.
        tw_merge(tokens.join(" "))
    } else {
        tw_merge(tokens.join(" "))
    };

    Ok(RString::new(&merged))
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = define_module("TailMerge")?;
    // -1 = variable arity (positional + kw-hash)
    module.define_singleton_method("merge", function!(merge_tailwind_classes, -1))?;
    Ok(())
}
