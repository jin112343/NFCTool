package com.nfctools

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter
import androidx.viewpager2.widget.ViewPager2
import com.nfctools.databinding.ActivityTutorialBinding

class TutorialActivity : AppCompatActivity() {

    private lateinit var binding: ActivityTutorialBinding
    private lateinit var tutorialAdapter: TutorialAdapter
    private val tutorialPages = listOf(
        TutorialPage(
            title = "NFC Tools へようこそ",
            description = "NFCタグの読み取り、書き込み、削除が簡単にできるアプリです。",
            imageRes = R.drawable.ic_read
        ),
        TutorialPage(
            title = "読み取り機能",
            description = "NFCタグをスマートフォンの背面に近づけるだけで、簡単に情報を読み取れます。",
            imageRes = R.drawable.ic_read
        ),
        TutorialPage(
            title = "書き込み機能",
            description = "テキストやURLなどの情報をNFCタグに簡単に書き込むことができます。",
            imageRes = R.drawable.ic_write
        ),
        TutorialPage(
            title = "削除機能",
            description = "NFCタグの情報を安全に削除して、新しい情報を書き込む準備ができます。",
            imageRes = R.drawable.ic_delete
        )
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityTutorialBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupViewPager()
        setupButtons()
        setupDots()
    }

    private fun setupViewPager() {
        tutorialAdapter = TutorialAdapter(this, tutorialPages)
        binding.viewPager.adapter = tutorialAdapter

        binding.viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                updateDots(position)
                updateButtons(position)
            }
        })
    }

    private fun setupButtons() {
        binding.btnSkip.setOnClickListener {
            finish()
        }

        binding.btnNext.setOnClickListener {
            val currentItem = binding.viewPager.currentItem
            if (currentItem < tutorialPages.size - 1) {
                binding.viewPager.currentItem = currentItem + 1
            } else {
                finish()
            }
        }
    }

    private fun setupDots() {
        val dots = Array(tutorialPages.size) { ImageView(this) }

        for (i in dots.indices) {
            dots[i] = ImageView(this)
            dots[i].setImageDrawable(ContextCompat.getDrawable(this, R.drawable.dot_inactive))

            val params = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            params.setMargins(8, 0, 8, 0)

            binding.dotsIndicator.addView(dots[i], params)
        }

        dots[0].setImageDrawable(ContextCompat.getDrawable(this, R.drawable.dot_active))
    }

    private fun updateDots(position: Int) {
        for (i in 0 until binding.dotsIndicator.childCount) {
            val dot = binding.dotsIndicator.getChildAt(i) as ImageView
            if (i == position) {
                dot.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.dot_active))
            } else {
                dot.setImageDrawable(ContextCompat.getDrawable(this, R.drawable.dot_inactive))
            }
        }
    }

    private fun updateButtons(position: Int) {
        if (position == tutorialPages.size - 1) {
            binding.btnNext.text = getString(R.string.done)
        } else {
            binding.btnNext.text = getString(R.string.next)
        }
    }
}

data class TutorialPage(
    val title: String,
    val description: String,
    val imageRes: Int
)

class TutorialAdapter(
    fragmentActivity: FragmentActivity,
    private val pages: List<TutorialPage>
) : FragmentStateAdapter(fragmentActivity) {

    override fun getItemCount(): Int = pages.size

    override fun createFragment(position: Int): Fragment {
        return TutorialPageFragment.newInstance(pages[position])
    }
}

class TutorialPageFragment : Fragment() {

    companion object {
        private const val ARG_PAGE = "page"

        fun newInstance(page: TutorialPage): TutorialPageFragment {
            val fragment = TutorialPageFragment()
            val args = Bundle()
            args.putString("title", page.title)
            args.putString("description", page.description)
            args.putInt("imageRes", page.imageRes)
            fragment.arguments = args
            return fragment
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.tutorial_page, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        val title = arguments?.getString("title") ?: ""
        val description = arguments?.getString("description") ?: ""
        val imageRes = arguments?.getInt("imageRes") ?: 0

        view.findViewById<TextView>(R.id.tutorial_title).text = title
        view.findViewById<TextView>(R.id.tutorial_description).text = description
        view.findViewById<ImageView>(R.id.tutorial_image).setImageResource(imageRes)
    }
}