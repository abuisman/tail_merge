use magnus::{define_module, function, prelude::*, Error, RArray, RString, Value};
use rustui_merge::merge::tw_merge;

fn merge_tailwind_classes(arg: Value) -> Result<RString, Error> {
    let mut class_strings = Vec::new();

    if let Ok(rstring) = RString::try_convert(arg.clone()) {
        // If it's a string, split on spaces
        let s = rstring.to_string()?;
        class_strings.extend(s.split_whitespace().map(|s| s.to_string()));
    } else if let Ok(rarray) = RArray::try_convert(arg) {
        // If it's an array, process as before
        for arg in rarray.each() {
            let rstring: RString = RString::try_convert(arg?)?;
            class_strings.push(rstring.to_string()?);
        }
    } else {
        return Err(Error::new(
            magnus::exception::type_error(),
            "Expected String or Array of Strings as argument",
        ));
    }

    let merged = tw_merge(class_strings.join(" "));
    Ok(RString::new(&merged))
}

#[magnus::init]
fn init() -> Result<(), Error> {
    let module = define_module("TailMerge")?;
    module.define_singleton_method("merge", function!(merge_tailwind_classes, 1))?;
    Ok(())
}
