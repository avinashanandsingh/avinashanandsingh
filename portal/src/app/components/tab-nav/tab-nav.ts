import { CommonModule, NgComponentOutlet } from '@angular/common';
import {
  ChangeDetectorRef,
  Component,
  EventEmitter,
  Input,
  OnChanges,
  OnDestroy,
  OnInit,
  Output,
  SimpleChanges,
} from '@angular/core';
export interface Tab {
  id: string;
  title: string;
  icon?: string;
  component?: any; // Type<any>
}
@Component({
  selector: 'app-tab-nav',
  imports: [CommonModule, NgComponentOutlet],
  templateUrl: './tab-nav.html',
  styleUrl: './tab-nav.css',
})
export class TabNav implements OnChanges, OnInit, OnDestroy {
  @Input() tabs: Tab[] = [];
  @Input() activeTabId: string = '';
  @Output() tabChange = new EventEmitter<string>();
  // Holds the currently active Tab object
  public activeTab: Tab | null = null;

  constructor(private cdRef: ChangeDetectorRef) {}

  ngOnInit() {
    this.updateActiveTab();
  }
  ngOnDestroy(): void {
    throw new Error('Method not implemented.');
  }
  ngOnChanges(changes: SimpleChanges): void {
    if (changes['activeTabId'] || changes['tabs']) {
      this.updateActiveTab();
    }
  }

  onTabClick(tabId: string): void {
    this.activeTabId = tabId;
    this.updateActiveTab();
    this.tabChange.emit(tabId);
    this.cdRef.detectChanges();
  }

  private updateActiveTab(): void {
    if (this.tabs.length > 0) {
      // Find the active tab or default to the first one if ID not set
      const activeTab = this.tabs.find((t) => t.id === this.activeTabId) || this.tabs[0];
      this.activeTab = activeTab;
    }
  }
}
