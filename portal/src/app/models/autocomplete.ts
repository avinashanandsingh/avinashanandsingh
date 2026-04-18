export interface IAutocompleteItem {
  id: string | number;
  value: string;
  label: string;
  description?:string;
  image?: string; // Optional avatar/image
  status?: 'active' | 'inactive'; // Optional status filter
}

export interface IAutocompleteConfig {
  minLength?: number;
  maxItems?: number;
  debounce?: number;
  showImage?: boolean;
  showStatus?: boolean;
  placeholder?: string;
  noResultsMessage?: string;
  loadingMessage?: string;
}
