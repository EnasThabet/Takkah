import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import dotenv from "dotenv";
import { createClient } from "@supabase/supabase-js";
import { Telegraf } from "telegraf";

dotenv.config();

const app = express();

// CORS
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "DELETE", "PUT"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(bodyParser.json());

// Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);

//
// ========== API ENDPOINTS ==========
//

// تسجيل مستخدم جديد
app.post("/register", async (req, res) => {
  const { username, phone_number, password_hash } = req.body;
  console.log("Received /register:", req.body);

  if (!username || !phone_number || !password_hash)
    return res.status(400).json({ message: "Missing fields" });

  try {
    const { data: existing, error: checkError } = await supabase
      .from("users")
      .select("*")
      .or(`username.eq.${username},phone_number.eq.${phone_number}`);

    if (checkError) {
      console.error("Supabase check error:", checkError);
      return res.status(500).json({ message: checkError.message });
    }

    if (existing.length > 0)
      return res.status(400).json({ message: "User already exists" });

    const { error } = await supabase.from("users").insert([
      { username, phone_number, password_hash }
    ]);

    if (error) {
      console.error("Supabase insert error:", error);
      return res.status(500).json({ message: error.message });
    }

    res.json({ message: "User registered successfully ✅" });

  } catch (err) {
    console.error("Server error:", err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// جلب التقارير
app.get("/reports", async (req, res) => {
  const { data, error } = await supabase
    .from("traffic_reports")
    .select("*")
    .order("timestamp", { ascending: false });

  if (error) return res.status(500).json({ message: error.message });
  res.json(data);
});

// حذف البيانات القديمة
app.delete("/cleanup", async (req, res) => {
  const { error } = await supabase.rpc("delete_old_reports");
  if (error) return res.status(500).json({ message: error.message });

  res.json({ message: "Old reports deleted 🧹" });
});

// تسجيل الدخول
app.post("/login", async (req, res) => {
  const { username, password_hash } = req.body;
  console.log("Received /login:", req.body);

  if (!username || !password_hash)
    return res.status(400).json({ message: "Missing fields" });

  try {
    const { data, error } = await supabase
      .from("users")
      .select("*")
      .or(`username.eq.${username},phone_number.eq.${username}`)
      .eq("password_hash", password_hash);

    if (error) return res.status(500).json({ message: error.message });
    if (data.length === 0)
      return res.status(401).json({ message: "بيانات الدخول غير صحيحة" });

    res.json({ message: "Login successful", user: data[0] });
  } catch (err) {
    console.error("Server error:", err);
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// بدء السيرفر
const port = process.env.PORT || 3000;
app.listen(port, () => console.log(`🚀 Server running on port ${port}`));


//
// ========== TELEGRAM BOT SECTION ==========
//

if (!process.env.BOT_TOKEN) {
  console.error("❌ Missing BOT_TOKEN in .env file");
} else {
  const bot = new Telegraf(process.env.BOT_TOKEN);

  // أمر /start (رسائل خاصة فقط)
  bot.start(async (ctx) => {
    if (ctx.chat.type !== "private") return;

    const chatId = ctx.chat.id;
    const username = ctx.chat.username || "Unknown";
    const firstName = ctx.chat.first_name || "";

    const { data: existing } = await supabase
      .from("telegram_users")
      .select("*")
      .eq("chat_id", chatId);

    if (!existing || existing.length === 0) {
      await supabase.from("telegram_users").insert([
        { chat_id: chatId, username, first_name: firstName }
      ]);
    }

    ctx.reply(`👋 أهلاً ${firstName}!`);
  });

  //
  // 🔥 استلام رسائل الجروبات بدون رد
  //
  bot.on("message", async (ctx) => {

    if (ctx.chat.type === "group" || ctx.chat.type === "supergroup") {

      const msg = ctx.message.text || ctx.message.caption;
      if (!msg) return;

      console.log("📩 New raw message:", msg);

      const { error } = await supabase.from("telegram_raw_messages").insert([
        {
          message: msg,
          source: "telegram",
        },
      ]);

      if (error) console.error("❌ Supabase insert error:", error);
      else console.log("✅ Message saved to Supabase");
    }

  });

  // شغل البوت
  bot.launch();
  console.log("🤖 Telegram bot is running (polling mode)...");
}
