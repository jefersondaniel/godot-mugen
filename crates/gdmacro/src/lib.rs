extern crate proc_macro;

use proc_macro::TokenStream;
use quote::quote;
use syn::{parse_macro_input, ItemEnum};

#[proc_macro_attribute]
pub fn godot_enum(
    _attr: TokenStream,
    item: TokenStream,
) -> TokenStream {
    // 1. Parse the enum
    let input = parse_macro_input!(item as ItemEnum);
    let name = &input.ident;
    let variants: Vec<_> = input.variants.iter().map(|v| &v.ident).collect();

    // 2. Pick the first variant as Default
    let default = &variants[0];

    // 3. Build match arms for get_property
    let get_arms = variants.iter().map(|v| {
        quote! {
            #name::#v => stringify!(#v).into(),
        }
    });

    // 4. Build match arms for set_property
    let set_arms = variants.iter().map(|v| {
        quote! {
            stringify!(#v) => *self = #name::#v,
        }
    });

    // 5. Generate the expanded code
    let expanded = quote! {
        // Re-emit the original enum
        #input

        // Default = first variant
        impl Default for #name {
            fn default() -> Self {
                #name::#default
            }
        }

        // Var impl
        impl godot::prelude::Var for #name {
            fn get_property(&self) -> <Self as godot::prelude::GodotConvert>::Via {
                match self {
                    #(#get_arms)*
                }
            }

            fn set_property(&mut self, value: <Self as godot::prelude::GodotConvert>::Via) {
                match value.to_string().as_str() {
                    #(#set_arms)*
                    _ => {}
                }
            }
        }

        impl Into<Variant> for #name {
            fn into(self) -> Variant {
                Variant::from(self)
            }
        }

        // Debug impl
        impl std::fmt::Debug for #name {
            fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
                write!(f, "{}", self.get_property())
            }
        }
    };

    expanded.into()
}
