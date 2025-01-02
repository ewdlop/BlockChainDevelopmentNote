#![cfg_attr(not(feature = "std"), no_std)]

pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
    use frame_support::{
        dispatch::DispatchResult,
        pallet_prelude::*,
        traits::{Currency, ReservableCurrency},
    };
    use frame_system::pallet_prelude::*;
    use sp_runtime::traits::CheckedSub;

    #[pallet::pallet]
    #[pallet::generate_store(pub(super) trait Store)]
    pub struct Pallet<T>(_);

    // Configure the pallet
    #[pallet::config]
    pub trait Config: frame_system::Config {
        type ETHCurrency: Currency<Self::AccountId> + ReservableCurrency<Self::AccountId>;
        type USDTokenCurrency: Currency<Self::AccountId>;
        type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
    }

    #[pallet::event]
    #[pallet::generate_deposit(pub(super) fn deposit_event)]
    pub enum Event<T: Config> {
        USDTokenMinted { account: T::AccountId, amount: u32 },
        ETHUsedForMinting { account: T::AccountId, eth_amount: u32 },
    }

    #[pallet::error]
    pub enum Error<T> {
        InsufficientETHCollateral,
        InvalidMintingAmount,
    }

    #[pallet::call]
    impl<T: Config> Pallet<T> {
        /// Mint USDToken by paying ETH as collateral
        #[pallet::weight(10_000)]
        pub fn mint_usd_tokens(
            origin: OriginFor<T>,
            usd_amount: u32,
        ) -> DispatchResult {
            let sender = ensure_signed(origin)?;

            // Define the ETH cost per USDToken (e.g., 1 ETH for 100 USD)
            let eth_per_usd: u32 = 1; // Simplified; in production, use dynamic pricing.

            // Calculate the required ETH amount
            let required_eth = usd_amount.checked_mul(eth_per_usd).ok_or(Error::<T>::InvalidMintingAmount)?;

            // Ensure the sender has enough ETH
            ensure!(
                T::ETHCurrency::free_balance(&sender) >= required_eth.into(),
                Error::<T>::InsufficientETHCollateral
            );

            // Reserve ETH from the sender's account
            T::ETHCurrency::reserve(&sender, required_eth.into())?;

            // Mint USDToken to the sender
            T::USDTokenCurrency::deposit_creating(&sender, usd_amount.into());

            // Emit events
            Self::deposit_event(Event::ETHUsedForMinting {
                account: sender.clone(),
                eth_amount: required_eth,
            });
            Self::deposit_event(Event::USDTokenMinted {
                account: sender,
                amount: usd_amount,
            });

            Ok(())
        }
    }
}
