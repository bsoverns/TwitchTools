using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TwitchTools
{
    internal class TwitchUserChat
    {
        public string UserName { get; set; }
        public string ChatMessage { get; set; }
        public string ChannelName { get; set; }
        public bool IsFlagged { get; set; }
        public string FlaggedReason { get; set; }
    }
}
